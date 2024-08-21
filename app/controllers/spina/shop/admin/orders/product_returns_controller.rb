module Spina::Shop
  module Admin
    module Orders
      class ProductReturnsController < AdminController
        before_action :set_order
        
        def new
          @product_return = @order.product_returns.build
        end
        
        def edit
          @product_return = @order.product_returns.open.find(params[:id])
        end
        
        def create
          @product_return = ProductReturn.new(product_return_params)
          
          if @product_return.save
            redirect_to spina.shop_admin_order_path(@order)
          else
            render :new, status: :unprocessable_entity
          end
        end
        
        def update
          @product_return = @order.product_returns.open.find(params[:id])
          
          if @product_return.update(product_return_params)
            redirect_to spina.shop_admin_order_path(@order)
          else
            render :edit, status: :unprocessable_entity
          end
        end
        
        def close
          @product_return = @order.product_returns.open.find(params[:id])
          @product_return.close!(actor: current_spina_user.name)
          redirect_to spina.shop_admin_order_path(@order)
        end
        
        def destroy
          @product_return = @order.product_returns.open.find(params[:id])
          @product_return.destroy
          redirect_to spina.shop_admin_order_path(@order)
        end
        
        private
        
          def product_return_params
            params.require(:product_return).permit(:note, product_return_items_attributes: [:id, :quantity, :product_id, :returned_quantity]).merge(order_id: @order.id)
          end
        
          def set_order
            @order = Order.find(params[:order_id])
          end
        
      end
    end
  end
end
