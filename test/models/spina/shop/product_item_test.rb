require 'test_helper'

module Spina
  class ProductItemTest < ActiveSupport::TestCase
    
    setup do
      @product_item = FactoryGirl.create :product_item_with_stock
    end

    test "Product item can be created" do
      assert_not_nil @product_item
    end

    test "Product item has stock" do
      assert @product_item.in_stock?
    end

    test "New product item has more stock" do
      product_item = FactoryGirl.create :product_item_with_stock, stock_level: 80
      assert_equal product_item.stock_level, 80
    end

  end
end
