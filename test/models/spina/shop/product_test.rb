require 'test_helper'

module Spina::Shop
  class ProductTest < ActiveSupport::TestCase
    
    setup do
      @product = FactoryBot.create :product
    end

    test "Product can be created" do
      assert_not_nil @product
    end

    test "Product is valid" do
      assert @product.valid?
    end

  end
end
