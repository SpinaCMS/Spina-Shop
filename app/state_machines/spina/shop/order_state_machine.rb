module Spina::Shop
  class OrderStateMachine
    include Statesman::Machine

    state :building, initial: true
    state :confirming
    state :received
    state :paid
    state :preparing
    state :ready_for_shipment
    state :shipped
    state :ready_for_pickup
    state :picked_up
    state :delivered
    state :failed # Final state
    state :cancelled # Final state
    state :refunded # Final state

    transition from: :building,         to: [:confirming]
    transition from: :confirming,       to: [:received, :cancelled, :failed]
    transition from: :received,         to: [:paid, :preparing, :cancelled, :failed, :refunded]
    transition from: :paid,             to: [:preparing, :shipped, :ready_for_pickup, :refunded]
    transition from: :preparing,        to: [:paid, :shipped, :ready_for_pickup, :refunded, :cancelled]
    transition from: :shipped,          to: [:paid, :delivered, :refunded, :cancelled]
    transition from: :ready_for_pickup, to: [:paid, :picked_up, :refunded, :cancelled]
    transition from: :picked_up,        to: [:paid, :refunded, :cancelled]
    transition from: :delivered,        to: [:paid, :refunded, :cancelled]
    transition from: :refunded,         to: [:refunded] 

    guard_transition(to: :confirming) do |order, transition|
      # Are all product items in stock and details right? Do we even have any order items?
      order.everything_valid? && order.order_items.any?
    end

    before_transition(to: :confirming) do |order, transition|
      # Generate order number
      order.update!(order_number: OrderNumberGenerator.generate!)

      # Allocate stock baby!
      AllocateStock.new(order).allocate

      # Cache prices, metadata and delivery
      CacheOrder.new(order).cache

      # Apply gift card
      order.apply_gift_cards! if order.gift_cards.any?

      # Create customer if necessary
      CustomerGenerator.new(order).generate!

      # Add address to customer if it doesn't have any addresses
      StoreAddress.new(order).store! if order.customer.addresses.none?

      # Confirm order
      order.update!(confirming_at: Time.zone.now)
    end

    guard_transition(to: :cancelled) do |order, transition|
      order.sales_invoice.blank?
    end

    before_transition(to: :cancelled) do |order, transition|
      order.update!(cancelled_at: Time.zone.now)

      # Stock weer terugzetten
      DeallocateStock.new(order).deallocate

      # Remove gift card
      order.remove_gift_cards! if order.gift_cards.any?
    end

    after_transition(to: :cancelled) do |order, transition|
      # Duplicate order voor nieuw winkelmandje
      order.duplicate!

      # Remove discount (after copying it to the new duplicated order)
      order.remove_discount! if order.discount.present?
    end

    after_transition(to: :received) do |order, transition|
      # Send mail and shit
      order.update!(received_at: Time.zone.now)
    end

    before_transition(to: :failed) do |order, transition|
      order.update!(failed_at: Time.zone.now)

      # Stock weer terugzetten
      DeallocateStock.new(order).deallocate

      # Remove gift card
      order.remove_gift_cards! if order.gift_cards.any?

      # Remove discount
      order.remove_discount! if order.discount.present?
    end

    after_transition(to: :failed) do |order, transition|
      order.duplicate!
    end

    guard_transition(to: :paid) do |order, transition|
      !order.paid?
    end

    before_transition(to: :paid) do |order, transition|
      order.update!(paid_at: Time.zone.now)
    end

    after_transition(to: :preparing) do |order, transition|
      order.update!(order_prepared_at: Time.zone.now)
    end
    
    guard_transition(to: :shipped) do |order, transition|
      order.requires_shipping?
    end

    guard_transition(to: :ready_for_pickup) do |order, transition|
      !order.requires_shipping?
    end
    
    after_transition(to: :ready_for_pickup) do |order, transition|
      order.update!(ready_for_pickup_at: Time.zone.now)
    end

    after_transition(to: :picked_up) do |order, transition|
      order.update!(picked_up_at: Time.zone.now)
    end

    after_transition(to: :shipped) do |order, transition|
      order.update!(shipped_at: Time.zone.now)
    end

    after_transition(to: :delivered) do |order, transition|
      order.update!(delivered_at: Time.zone.now)
    end

    guard_transition(to: :refunded) do |order, transition, metadata|
      order.sales_invoice.present? && (metadata["entire_order"] || metadata["refund_lines"].to_h.any?{|id, line| line["refund"]})
    end

    before_transition(to: :refunded) do |order, transition|
      generator = CreditInvoiceGenerator.new(order.sales_invoice)
      generator.generate!(transition.metadata["refund_lines"], transition.metadata["refund_delivery_costs"])

      # Refund stock if necessary
      refunder = RefundStock.new(order, category: order.refund_reason)
      refunder.allocate(transition.metadata["refund_lines"]) if transition.metadata["deallocate_stock"]
    end

    after_transition(to: :refunded) do |order, transition|
      order.update!(refunded_at: Time.zone.now)
    end

  end
end
