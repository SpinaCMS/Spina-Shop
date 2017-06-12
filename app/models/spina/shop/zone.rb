module Spina::Shop
  class Zone < ApplicationRecord
    include TaxRateable

    # A zone can have multiple members example: EU --> Countries
    belongs_to :parent, class_name: "Spina::Shop::Zone", optional: true
    has_many :members, class_name: "Spina::Shop::Zone", foreign_key: :parent_id, dependent: :nullify
  end
end