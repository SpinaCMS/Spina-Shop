module Spina
  module Shop
    class TaxRate < ApplicationRecord
      belongs_to :tax_group
      belongs_to :tax_rateable, polymorphic: true, optional: true

      # Rates without a tax rateable like a zone is considered the default
      scope :default_rate, -> { where(tax_rateable: nil) }

      validates :rate, numericality: true, presence: true
      validates :tax_rateable_type, uniqueness: {scope: [:tax_group_id, :tax_rateable_id]}
    end
  end
end