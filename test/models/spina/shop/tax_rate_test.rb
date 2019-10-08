require 'test_helper'

module Spina::Shop
  class TaxRateTest < ActiveSupport::TestCase

    setup do
      @tax_group = FactoryBot.create :tax_group
    end

    test "Default tax rate" do
      assert_not_nil @tax_group.default_tax_rate
    end

    test "Tax groups default tax rate" do
      assert_equal @tax_group.default_tax_rate.rate, BigDecimal(21)
    end

    test "Tax groups multiple rates" do
      assert_equal 5, @tax_group.tax_rates.count
    end

  end
end
