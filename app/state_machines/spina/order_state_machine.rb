module Spina
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
    transition from: :received,       to: [:paid]
    transition from: :paid,           to: [:order_picking, :delivered]
    transition from: :order_picking,  to: [:shipped, :picked_up]
    transition from: :shipped,        to: [:delivered, :refunded]
    transition from: :picked_up,      to: [:delivered, :refunded]
    transition from: :delivered,      to: :refunded

    guard_transition(to: :confirming) do |order, transition|
      # Are all product items in stock and details right?
      order.validate_details = true
      order.validate_stock = true
      order.valid?
    end

    after_transition(to: :confirming) do |order, transition|
      # Generate that number
      order.update_attributes!(order_number: OrderNumberGenerator.generate, confirming_at: Time.zone.now)

      # Allocate stock baby!
      order.order_items.each(&:allocate_unallocated_stock!)

      # Cache prices 
      order.order_items.each(&:cache_pricing!)

      # Cache delivery option
      order.cache_delivery_option!

      unless order.pos?
        # Create customer if necessary
        CustomerGenerator.new(order).generate!

        # Create payment
        payment = Spina::Mollie.client.payments.create(
          amount: order.total,
          description: "Bestelling ##{order.order_number}",
          redirectUrl: "#{Rails.application.config.host}/orders/#{order.id}/callback",
          method: order.payment_method,
          issuer: order.payment_issuer,
          metadata: {
            order_id: order.id
          }
        )
        order.update_attributes!(payment_id: payment.id, payment_url: payment.getPaymentUrl)
      end
    end

    after_transition(to: :cancelled) do |order, transition|
      order.update_attributes!(cancelled_at: Time.zone.now)

      # Stock weer terugzetten
      order.order_items.each(&:unallocate_allocated_stock)

      # Duplicate order voor nieuw winkelmandje
      order.duplicate!
    end

    after_transition(to: :received) do |order, transition|
      # Send mail and shit
      order.update_attributes!(received_at: Time.zone.now)
    end

    after_transition(to: :failed) do |order, transition|
      order.update_attributes!(failed_at: Time.zone.now)

      # Stock weer terugzetten
      order.order_items.each(&:unallocate_allocated_stock)

      # Order duplicate
      order.duplicate!
    end

    guard_transition(from: :paid, to: :delivered) do |order, transition|
      order.pos?
    end

    guard_transition(to: :paid) do |order, transition|
      if order.online?
        payment = Spina::Mollie.client.payments.get(order.payment_id)
        payment.paid?
      else
        order.pos?
      end
    end

    after_transition(to: :paid) do |order, transition|
      # Bestelling mailtje met nieuwe factuur
      # Genereer factuur
      # Exact bijwerken
      # Factuur versturen enzo
      order.update_attributes!(paid_at: Time.zone.now)

      if order.online?
        if invoice = InvoiceGenerator.new(order).generate!
          # TODO: Background job Exact online
          # Spina::ExactOnline.invoice_to_sales_entry(invoice)
        end
      end
    end

    guard_transition(to: :order_picking) do |order, transition|
      order.online?
    end

    after_transition(to: :order_picking) do |order, transition|
      order.update_attributes!(order_picked_at: Time.zone.now)
      Spina::Printnode.print("#{Rails.application.config.host}/admin/orders/#{order.id}/packing_slip.pdf")
    end

    guard_transition(to: :shipped) do |order, transition|
      order.online? && order.requires_shipping?
    end

    guard_transition(to: :picked_up) do |order, transition|
      order.online?
    end

    after_transition(to: :picked_up) do |order, transition|
      order.update_attributes!(picked_up_at: Time.zone.now)
    end

    after_transition(to: :shipped) do |order, transition|
      # Bestelling mailtje met verzendgegevens
      # Set shipped_at
      order.update_attributes!(shipped_at: Time.zone.now)

      to_address = EasyPost::Address.create(
        name: order.delivery_name,
        street1: order.delivery_address,
        city: order.delivery_city,
        zip: order.delivery_postal_code,
        country: order.delivery_country.iso_3166,
        phone: order.phone
      )

      from_address = EasyPost::Address.create(
        name: "Bram Jetten",
        street1: "De Flammert 1408",
        city: "Nieuw-Bergen",
        state: "Limburg",
        zip: "5854 NE",
        country: "NL",
        phone: "0618606826"
      )

      parcel = EasyPost::Parcel.create(
        weight: 2000,
        width: 30.7,
        length: 68.8,
        height: 21.6
        # predefined_package: "Parcel"
      )

      shipment = EasyPost::Shipment.create(
        to_address: to_address,
        from_address: from_address,
        parcel: parcel,
        options: {
          label_format: "PDF"
        }
      )
      shipment.buy(rate: shipment.lowest_rate)

      shipment_2 = EasyPost::Shipment.create(
        to_address: to_address,
        from_address: from_address,
        parcel: parcel,
        options: {
          label_format: "PDF"
        }
      )
      shipment_2.buy(rate: shipment_2.lowest_rate)

      batch = EasyPost::Batch.create(
        shipments: [{id: shipment.id}, {id: shipment_2.id}]
      )

      hoi = batch.label({file_format: 'pdf'})
      pdf_url = batch.label_url
      Spina::Printnode.print(pdf_url)
    end

    after_transition(to: :delivered) do |order, transition|
      # Pakketje is afgeleverd, review inplannen?
      order.update_attributes!(delivered_at: Time.zone.now)
    end
  end
end
