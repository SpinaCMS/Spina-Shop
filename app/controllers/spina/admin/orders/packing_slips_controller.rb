module Spina
  module Admin
    module Orders
      class PackingSlipsController < ShopController
        skip_before_action :authorize_user, only: :show
        load_and_authorize_resource :order, class: "Spina::Order"
        skip_load_and_authorize_resource :order, only: :show

        def show
          @order = Order.find(params[:order_id])
          render_pdf
        end

        def create
          @order.transition_to! :order_picking
          redirect_to [:admin, @order]
        end

        private

          def render_pdf
            pdf = PackingSlipPdf.new(@order)
            send_data pdf.render, filename: "pakbon_#{@order.number}.pdf", type: "application/pdf"
          end
      end
    end
  end
end