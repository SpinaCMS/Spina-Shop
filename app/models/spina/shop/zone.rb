module Spina::Shop
  class Zone < ApplicationRecord
    belongs_to :parent, class_name: "Spina::Shop::Zone", foreign_key: :parent_id
  end
end