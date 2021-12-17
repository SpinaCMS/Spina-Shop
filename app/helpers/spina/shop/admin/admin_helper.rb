module Spina::Shop
  module Admin
    module AdminHelper

      def product_image_tag(product_image, variant: {})
        image_tag main_app.url_for(product_image.file.variant(variant))
      rescue 
        ""
      end
      
      def format_datetime(datetime)
        formatted = if datetime.to_date == Date.today
          l(datetime, format: "Vandaag, %H:%M")
        elsif datetime.to_date == Date.yesterday
          l(datetime, format: "Gisteren, %H:%M")
        elsif datetime.to_date == Date.tomorrow
          l(datetime, format: "Morgen, %H:%M")
        else
          l(datetime, format: "%e %b. %y, %H:%M")
        end
        
        if datetime.is_a? DateTime
          formatted << l(datetime, format: ", %H:%M")
        end
        
        formatted
      end
      
    end
  end
end