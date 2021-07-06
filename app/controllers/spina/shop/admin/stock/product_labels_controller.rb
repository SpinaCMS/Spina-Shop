module Spina::Shop
  module Admin
    module Stock
      class ProductLabelsController < AdminController

        def new
          @products = Product.where(id: params[:product_ids])
          @product_labels = @products.map do |product|
            {tht: (l(product.expiration_date, format: "%m-%Y") if product.expiration_date), name: product.full_name, location: product.location, product: product, locations: [product.product_locations.joins(:location_code).pluck(:code), product.location].map(&:presence).compact.uniq}
          end
        end

        def create
          pdf = ProductLabelsPdf.new(product_label_params)
          send_data pdf.render, filename: "labels.pdf", type: "application/pdf"
        end

        private

          def product_label_params
            params["product_labels"]
          end

      end
    end
  end
end