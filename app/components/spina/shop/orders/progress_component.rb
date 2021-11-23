module Spina::Shop
  module Orders
    class ProgressComponent < ApplicationComponent
      attr_reader :order
      
      def initialize(order)
        @order = order
      end
      
      def label
        I18n.t("spina.shop.orders.states.#{order.current_state}")
      end
      
      private
      
        def classes
          "#{bg_color} #{text_color} py-0.5 px-1 inline-block rounded whitespace-nowrap overflow-ellipsis overflow-hidden"
        end
        
        def text_color
          case order.status_css_class
          when "success"
            "text-white"
          when "primary"
            "text-white"
          when "danger"
            "text-red-500"
          else
            "text-gray-700"
          end
        end
        
        def border_color
          case order.status_css_class
          when "success"
            "border-green-400"
          when "primary"
            "border-spina"
          when "danger"
            "border-gray-400"
          else
            "border-gray-400"
          end
        end
        
        def bg_color
          case order.status_css_class
          when "success"
            "bg-green-400"
          when "primary"
            "bg-spina"
          when "danger"
            "bg-gray-400"
          else
            "bg-gray-400"
          end
        end
      
    end
  end
end