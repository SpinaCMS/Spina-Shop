module Spina::Shop
  class InStockReminder < ApplicationRecord
    belongs_to :orderable, polymorphic: true

    validates :email, email: true, presence: true, uniqueness: {scope: [:orderable_id, :orderable_type]}
  end
end