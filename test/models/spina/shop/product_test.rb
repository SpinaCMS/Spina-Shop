require 'test_helper'

module Spina
  class ProductTest < ActiveSupport::TestCase
    
    setup do
      @product = FactoryGirl.create :product
    end

    test "Product can be created" do
      assert_not_nil @product
    end

    test "Product is valid" do
      assert @product.valid?
    end

  end
end
