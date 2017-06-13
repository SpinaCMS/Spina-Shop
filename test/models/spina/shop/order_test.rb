require 'test_helper'

module Spina::Shop
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
      assert_equal BigDecimal.new('12.50'), @order_with_order_items.total
    end

    test "Order sub total" do
      assert_equal BigDecimal.new('10.33'), @order_with_order_items.sub_total
    end

    test "Order with different country tax rate" do
      order = FactoryGirl.create :order_from_germany
      assert_equal BigDecimal.new('10.50'), order.sub_total
    end

    test "Order change tax rate by changing delivery country" do
      assert_equal BigDecimal.new('10.33'), @order_with_order_items.sub_total
      @order_with_order_items.delivery_country = FactoryGirl.create :germany
      assert_equal BigDecimal.new('10.50'), @order_with_order_items.sub_total
    end

  end
end

