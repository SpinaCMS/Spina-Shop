module Spina::Shop
  class OrderStateMachine
    include Statesman::Machine

    state :building, initial: true
    state :confirming
    state :received
    state :paid
    state :preparing
    state :shipped
    state :picked_up
    state :delivered
    state :failed # Final state
    state :cancelled # Final state
    state :refunded # Final state

    transition from: :building,   to: :confirming
    transition from: :confirming, to: [:received, :cancelled, :failed]
    transition from: :received,   to: [:paid, :preparing, :cancelled, :failed, :refunded]
    transition from: :paid,       to: [:preparing, :shipped, :picked_up, :refunded]
    transition from: :preparing,  to: [:paid, :shipped, :picked_up, :refunded, :cancelled]
    transition from: :shipped,    to: [:paid, :delivered, :refunded, :cancelled]
    transition from: :picked_up,  to: [:paid, :refunded, :cancelled]
    transition from: :delivered,  to: [:paid, :refunded, :cancelled]

    guard_transition(to: :confirming) do |order, transition|
      # Are all product items in stock and details right? Do we even have any order items?
      order.everything_valid? && order.order_items.any?
    end

    before_transition(to: :confirming) do |order, transition|
      # Generate order number
      order.update_attributes!(order_number: OrderNumberGenerator.generate!)

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
      order.update_attributes!(confirming_at: Time.zone.now)
    end

    guard_transition(to: :cancelled) do |order, transition|
      order.sales_invoice.blank?
    end

    before_transition(to: :cancelled) do |order, transition|
      order.update_attributes!(cancelled_at: Time.zone.now)

      # Stock weer terugzetten
      DeallocateStock.new(order).deallocate

      # Remove gift card
      order.remove_gift_cards! if order.gift_cards.any?

      # Remove discount
      order.remove_discount! if order.discount.present?
    end

    after_transition(to: :cancelled) do |order, transition|
      # Duplicate order voor nieuw winkelmandje
      order.duplicate!
    end

    after_transition(to: :received) do |order, transition|
      # Send mail and shit
      order.update_attributes!(received_at: Time.zone.now)
    end

    before_transition(to: :failed) do |order, transition|
      order.update_attributes!(failed_at: Time.zone.now)

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

    after_transition(to: :picked_up) do |order, transition|
      order.update_attributes!(picked_up_at: Time.zone.now)
    end

    after_transition(to: :shipped) do |order, transition|
      order.update_attributes!(shipped_at: Time.zone.now)
    end

    after_transition(to: :delivered) do |order, transition|
      order.update_attributes!(delivered_at: Time.zone.now)
    end

    guard_transition(to: :refunded) do |order, transition|
      order.sales_invoice.present?
    end

    before_transition(to: :refunded) do |order, transition|
      generator = CreditInvoiceGenerator.new(order.sales_invoice)
      generator.generate!(transition.metadata["refund_lines"], transition.metadata["refund_delivery_costs"])

      # Refund stock if necessary
      RefundStock.new(order).allocate(transition.metadata["refund_lines"]) if transition.metadata["deallocate_stock"]
    end

    after_transition(to: :refunded) do |order, transition|
      order.update!(refunded_at: Time.zone.now)
    end

  end
end
