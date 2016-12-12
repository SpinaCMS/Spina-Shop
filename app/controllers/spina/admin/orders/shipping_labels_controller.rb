module Spina
  module Admin
    module Orders
      class ShippingLabelsController < ShopController
        load_and_authorize_resource :order, class: "Spina::Order"

        def show
        end

        def create
          # Create label and print it or some shit
          @order.transition_to! :shipped
          redirect_to [:admin, @order]
        end
      end
    end
  end
end