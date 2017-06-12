require 'active_support/concern'

module Spina::Shop
  module TaxRateable
    extend ActiveSupport::Concern

    included do
      has_many :tax_rates, as: :tax_rateable, dependent: :restrict_with_exception
    end
  end
end