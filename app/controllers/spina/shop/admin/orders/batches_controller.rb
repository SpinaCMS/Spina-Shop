require 'zip'

module Spina::Shop
  module Admin
    module Orders
      class BatchesController < AdminController

        def create
          @orders = Order.where(id: params[:order_ids])

          case params[:batch_action]
          when "start_preparing"
            @orders.each do |order|
              order.transition_to("preparing", user: current_spina_user.name, ip_address: request.remote_ip)
            end
            flash[:success] = t('spina.shop.orders.start_preparing_success_html')
            redirect_back fallback_location: spina.shop_admin_orders_path
          when "start_shipping"
            @orders.each do |order|
              order.transition_to("shipped", user: current_spina_user.name, ip_address: request.remote_ip)
            end
            flash[:success] = t('spina.shop.orders.ship_order_success_html')
            redirect_back fallback_location: spina.shop_admin_orders_path
          when "start_preparing_and_shipping"
            @orders.each do |order|
              order.transition_to("preparing", user: current_spina_user.name, ip_address: request.remote_ip)
              order.transition_to("shipped", user: current_spina_user.name, ip_address: request.remote_ip)
            end
            flash[:success] = t('spina.shop.orders.start_preparing_and_ship_success_html')
            redirect_back fallback_location: spina.shop_admin_orders_path
          when "download_attachments"
            temp_file = Tempfile.new(["attachments", ".zip"])
            Zip::OutputStream.open(temp_file) { |zos| }

            Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
              @orders.each do |order|
                order.order_attachments.each do |order_attachment|
                  zipfile.add("#{order_attachment.name}/#{order.number}-#{order_attachment.id}.pdf", order_attachment.attachment.download.path)
                end
              end
            end

            zip_data = File.read(temp_file.path)

            send_data zip_data, filename: "attachments.zip", type: "application/zip", disposition: "attachment"
          end
        end

      end
    end
  end
end