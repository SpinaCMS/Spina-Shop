require 'test_helper'

module Spina
  class OrderTest < ActiveSupport::TestCase
    
    setup do
      @order = FactoryGirl.create :order
      @order_with_order_items = FactoryGirl.create :order_with_order_items
    end

    test "Order is created" do
      assert_not_nil @order
    end

    test "Blank order is not valid" do
      @order.validate_details = true
      assert_not @order.valid?
    end

    test "Order validate details" do
      order = FactoryGirl.create :order_with_details
      order.validate_details = true
      assert order.valid?
    end

    test "Order with payment method" do
      @order.validate_payment = true
      @order.assign_attributes(
        payment_method: 'Cash'
      )
      assert @order.valid?
    end

    test "Add order items to order" do
      product_item = FactoryGirl.create :product_item_with_stock, stock_level: 10
      @order.order_items.create(quantity: 1, orderable: product_item)
      @order.validate_stock = true
      assert @order.valid?
    end

    test "Order total" do
      assert_equal @order_with_order_items.total, BigDecimal.new('12.50')
    end

    test "Order sub total" do
      assert_equal @order_with_order_items.sub_total, BigDecimal.new('10.33')
    end

    test "Order with delivery method" do
      # @order.validate_delivery = true
      # @order.assign_attributes(
      #   delivery_method: nil
      # )
      # assert @order.valid?
    end

  end
end
