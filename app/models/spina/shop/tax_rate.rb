module Spina
  module Shop
    class TaxRate < ApplicationRecord
      belongs_to :tax_group

      validates :rate, numericality: true, presence: true

      validates :country_id, uniqueness: {scope: [:tax_group_id]}
    end
  end
end