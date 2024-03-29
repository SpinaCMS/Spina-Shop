module Spina::Shop
  module Admin
    module Orders
      class PackingSlipsController < AdminController
        skip_before_action :authenticate, only: :show

        def show
          @order = Order.find(params[:order_id])
          render_pdf
        end

        def create
          @order = Order.find(params[:order_id])
          @order.transition_to! :preparing, user: current_spina_user.name, ip_address: request.remote_ip
          redirect_to spina.shop_admin_order_path(@order)
        end

        private

          def render_pdf
            pdf = PackingSlipPdf.new(@order)
            send_data pdf.render, filename: "ps_#{@order.number}.pdf", type: "application/pdf"
          end
      end
    end
  end
end