module Spina::Shop
  module Admin
    module Orders
      class PaymentRemindersController < AdminController

        def create
          @order = Order.find(params[:order_id])
          OrderMailer.payment_reminder(@order.id).deliver_later
          @order.touch(:payment_reminder_sent_at)
          flash[:notice] = t('spina.shop.orders.payment_reminders.email_sent')
          flash[:notice_small] = t('spina.shop.orders.payment_reminders.customer_received_invoice')
          redirect_back fallback_location: spina.shop_admin_order_path(@order)
        end

      end
    end
  end
end