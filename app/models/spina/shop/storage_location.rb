module Spina::Shop
  class StorageLocation < ApplicationRecord
    has_many :locations, dependent: :restrict_with_exception
  end
end