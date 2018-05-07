module Spina::Shop
  class SupplyOrder < ApplicationRecord
    belongs_to :supplier

    has_many :ordered_supply, class_name: "Spina::Shop::OrderedSupply", dependent: :destroy

    scope :concept, -> { where(ordered_at: nil) }
    scope :incoming, -> { where(received_at: nil) }

    def ordered?
      ordered_at.present?
    end

    def received?
      received_at.present?
    end

    def status
      if ordered?
        if received?
          'received'
        else
          if expected_delivery == Date.today
            'expected_today'
          elsif expected_delivery < Date.today
            'late'
          else
            'pending'
          end
        end
      else
        'concept'
      end
    end

    def status_label
      case status
      when 'received'
        'success'
      when 'expected_today'
        'primary'
      when 'late'
        'alert'
      end
    end
  end
end