module Spina::Shop
  module Admin
    class ProductItemsController < AdminController

      def index
        @q = ProductItem.ransack(params[:q].permit!)
        @product_items = @q.result.page(params[:page]).per(25)

        results = @product_items.map do |product_item|
          { id: product_item.id, 
            name: product_item.short_description, 
            image_url: view_context.attachment_url(product_item.product.product_images.first, :file, :fit, 30, 30), 
            price: view_context.number_to_currency(product_item.price) }
        end
        render inline: {results: results, total_count: @q.result.count}.to_json
      end

    end
  end
end