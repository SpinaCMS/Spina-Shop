module Spina
  module Admin
    module Orders
      class PackingSlipsController < ShopController
        skip_before_action :authorize_spina_user, only: :show

        def show
          @order = Order.find(params[:order_id])
          render_pdf
        end

        def create
          @order = Order.find(params[:order_id])
          @order.transition_to! :order_picking, user: current_user.name, ip_address: request.remote_ip
          redirect_to [:admin, @order]
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