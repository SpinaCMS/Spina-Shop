module Spina::Shop
  class NumberSequence < ApplicationRecord
    validates :name, :next_number, presence: true
    validates :next_number, uniqueness: {scope: :name}

    def self.by_name(name)
      NumberSequence.where(name: name).first_or_create!
    end

    def increment!
      with_lock do
        number = next_number
        self.next_number = number + 1
        save!
        number
      end
    end
  end
end