module Spina::Shop
  class OrderStateMachine
    include Statesman::Machine

    state :building, initial: true
    state :confirming
    state :received
    state :paid
    state :order_picking
    state :shipped
    state :picked_up
    state :delivered
    state :failed
    state :cancelled
    state :refunded

    transition from: :building,       to: :confirming
    transition from: :confirming,     to: [:received, :cancelled, :failed]
    transition from: :received,       to: [:paid, :cancelled, :failed]
    transition from: :paid,           to: [:order_picking, :picked_up]
    transition from: :order_picking,  to: [:shipped, :picked_up]
    transition from: :shipped,        to: [:delivered, :refunded]
    transition from: :picked_up,      to: :refunded
    transition from: :delivered,      to: :refunded

    guard_transition(to: :confirming) do |order, transition|
      # Are all product items in stock and details right?
      order.everything_valid?
    end

    before_transition(to: :confirming) do |order, transition|
      # Generate that number
      order.update_attributes!(order_number: OrderNumberGenerator.generate!, confirming_at: Time.zone.now)

      # Allocate stock baby!
      order.order_items.each(&:allocate_unallocated_stock!)

      # Cache prices 
      order.order_items.each(&:cache_pricing!)
      order.order_items.each(&:cache_metadata!)

      # Cache delivery option
      order.cache_delivery_option! if order.delivery_option.present?

      # Apply gift card
      order.apply_gift_card! if order.gift_card.present?

      # Create customer if necessary
      CustomerGenerator.new(order).generate!
    end

    before_transition(to: :cancelled) do |order, transition|
      order.update_attributes!(cancelled_at: Time.zone.now)

      # Stock weer terugzetten
      order.order_items.each(&:unallocate_allocated_stock)

      # Remove gift card
      order.remove_gift_card! if order.gift_card.present?
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
      order.order_items.each(&:unallocate_allocated_stock)

      # Remove gift card
      order.remove_gift_card! if order.gift_card.present?
    end

    after_transition(to: :failed) do |order, transition|
      # Order duplicate
      order.duplicate!
    end

    before_transition(to: :paid) do |order, transition|
      # Update order to paid
      order.update_attributes!(paid_at: Time.zone.now)

      # Invoice
      InvoiceGenerator.new(order).generate!
    end

    after_transition(to: :order_picking) do |order, transition|
      order.update_attributes!(order_picked_at: Time.zone.now)
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

      OrderMailer.shipped(order).deliver_later
    end

    after_transition(to: :delivered) do |order, transition|
      # Pakketje is afgeleverd, review inplannen?
      order.update_attributes!(delivered_at: Time.zone.now)
    end
  end
end
