require 'zip'

module Spina::Shop
  module Admin
    module Orders
      class BatchesController < AdminController

        def create
          @orders = Order.where(id: params[:order_ids])
          
          if batch_transition_state
            BatchOrderTransitionJob.perform_later(
              @orders.ids, 
              batch_transition_state, 
              user: current_spina_user.name, ip_address: request.remote_ip
            )
            
            flash[:success] = "Bestellingen worden verwerkt"
            redirect_back fallback_location: spina.shop_admin_orders_path
          elsif params[:batch_action] == "download_attachments"
            data = download_attachments!
            send_data data, filename: "attachments.zip", type: "application/zip", disposition: "attachment"
          end
        end
        
        private
        
          def batch_transition_state
            case params[:batch_action]
            when "start_preparing"
              "preparing"
            when "start_paid"
              "paid"
            when "cancel"
              "cancelled"
            when "start_shipping"
              "shipped"
            when "start_preparing_and_shipping"
              %w[prepared shipped]
            else
              nil
            end
          end
          
          def download_attachments!
            temp_file = Tempfile.new(["attachments", ".zip"])
            Zip::OutputStream.open(temp_file) { |zos| }
            
            Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
              @orders.each do |order|
                order.order_attachments.each do |order_attachment|
                  zipfile.add("#{order_attachment.name}/#{order.number}-#{order_attachment.id}.pdf", order_attachment.attachment.download.path)
                end
              end
            end
            
            File.read(temp_file.path)
          end

      end
    end
  end
end