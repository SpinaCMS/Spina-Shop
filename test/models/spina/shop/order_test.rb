require 'test_helper'

module Spina::Shop
  class OrderTest < ActiveSupport::TestCase
    
    setup do
      @order = FactoryBot.create :order
      @order_with_order_items = FactoryBot.create :order_with_order_items
    end

    test "Order is created" do
      assert_not_nil @order
    end

    test "Blank order is not valid" do
      @order.validate_details = true
      assert_not @order.valid?
    end

    test "Order validate details" do
      order = FactoryBot.create :order_with_details
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
      product = FactoryBot.create :product_with_stock, stock_level: 10
      @order.order_items.create(quantity: 1, orderable: product)
      @order.validate_stock = true
      assert @order.valid?
    end

    test "Order total" do
      assert_equal BigDecimal('12.50'), @order_with_order_items.total
    end

    test "Order sub total" do
      assert_equal BigDecimal('10.33'), @order_with_order_items.total_excluding_tax
    end

    test "Order with different country tax rate" do
      order = FactoryBot.create :order_from_germany
      assert_equal BigDecimal('10.50'), order.total_excluding_tax
    end

    test "Business order from France no tax" do
      order = FactoryBot.create :business_order_from_france
      assert_equal order.delivery_country.parent, FactoryBot.create(:eu)
      assert_equal order.total_excluding_tax, order.total
    end

    test "Business order from Germany no tax" do
      order = FactoryBot.create :business_order_from_germany
      assert_equal order.business, true
      assert_equal order.delivery_country, FactoryBot.create(:germany)
      assert_equal order.total_excluding_tax, order.total
    end

    test "Order change tax rate by changing delivery country" do
      assert_equal BigDecimal('2.17'), @order_with_order_items.tax_amount
      @order_with_order_items.delivery_country = FactoryBot.create(:germany)
      @order_with_order_items.separate_delivery_address = true
      assert_equal BigDecimal('2.00'), @order_with_order_items.tax_amount
    end

  end
end

