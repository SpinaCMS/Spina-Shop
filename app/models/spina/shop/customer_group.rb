module Spina
  module Shop
    class CustomerGroup < ApplicationRecord
      belongs_to :parent, class_name: 'CustomerGroup', optional: true
      has_many :children, class_name: 'CustomerGroup', foreign_key: :parent_id
      has_many :customers, dependent: :restrict_with_exception

      scope :ordered, -> { order(:name) }

      validates :name, presence: true
    end
  end
end