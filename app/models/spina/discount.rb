module Spina
  class Discount < ApplicationRecord
    scope :active, -> { where('starts_at >= :today AND (expires_at IS NULL OR expires_at <= :today)', today: Date.today) }

    validates :code, unique: true
  end
end