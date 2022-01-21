module Spina::Shop
  module Admin
    module AdminHelper

      def product_image_tag(product_image, variant: {})
        image_tag main_app.url_for(product_image.file.variant(variant))
      rescue 
        ""
      end
      
    end
  end
end