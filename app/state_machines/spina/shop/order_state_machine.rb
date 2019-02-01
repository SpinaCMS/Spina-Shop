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
    state :failed
    state :cancelled
    state :refunded

    transition from: :building,   to: :confirming
    transition from: :confirming, to: [:received, :cancelled, :failed]
    transition from: :received,   to: [:paid, :preparing, :cancelled, :failed]
    transition from: :paid,       to: [:preparing, :shipped, :picked_up]
    transition from: :preparing,  to: [:paid, :shipped, :picked_up]
    transition from: :shipped,    to: [:delivered, :refunded]
    transition from: :picked_up,  to: :refunded
    transition from: :delivered,  to: :refunded

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
      order.apply_gift_card! if order.gift_card.present?

      # Create customer if necessary
      CustomerGenerator.new(order).generate!

      # Add address to customer if it doesn't have any addresses
      StoreAddress.new(order).store! if order.customer.addresses.none?

      # Confirm order
      order.update_attributes!(confirming_at: Time.zone.now)
    end

    before_transition(to: :cancelled) do |order, transition|
      order.update_attributes!(cancelled_at: Time.zone.now)

      # Stock weer terugzetten
      DeallocateStock.new(order).deallocate

      # Remove gift card
      order.remove_gift_card! if order.gift_card.present?

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
      order.remove_gift_card! if order.gift_card.present?

      # Remove discount
      order.remove_discount! if order.discount.present?
    end

    after_transition(to: :failed) do |order, transition|
      # Order duplicate
      order.duplicate!
    end

    before_transition(to: :paid) do |order, transition|
      # Don't do anything if it's already paid
      return if order.paid?

      # Update order to paid
      order.update_attributes!(paid_at: Time.zone.now)

      # Invoice
      InvoiceGenerator.new(order).generate!
    end

    after_transition(to: :preparing) do |order, transition|
      order.update_attributes!(order_prepared_at: Time.zone.now)
    end

    guard_transition(to: :shipped) do |order, transition|
      order.requires_shipping?
    end

    after_transition(to: :picked_up) do |order, transition|
      order.update_attributes!(picked_up_at: Time.zone.now)
    end

    after_transition(to: :shipped) do |order, transition|
      # Set shipped_at and send mail
      order.update_attributes!(shipped_at: Time.zone.now)
    end

    after_transition(to: :delivered) do |order, transition|
      # Pakketje is afgeleverd, review inplannen?
      order.update_attributes!(delivered_at: Time.zone.now)
    end
  end
end
