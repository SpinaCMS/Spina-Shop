module Spina::Shop
  class Zone < ApplicationRecord
    include TaxRateable

    belongs_to :parent, class_name: "Spina::Shop::Zone"
    has_many :members, class_name: "Spina::Shop::Zone", foreign_key: :parent_id, dependent: :nullify

    has_many :orders, dependent: :restrict_with_exception
  end
end