require 'test_helper'

module Spina
  module Admin
    class OrdersTest < ActionController::TestCase
      setup do
        @routes = ::Spina::Engine.routes
        @order = FactoryBot.create :order_with_order_items
      end

      test "Order has order items" do
        assert @order.order_items.count > 0
      end

      test "Order has order items that are in stock" do
        @order.validate_stock = true
        assert @order.valid?
      end
    end
  end
end
