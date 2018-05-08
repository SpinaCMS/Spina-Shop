module Spina::Shop
  class StockOrder < ApplicationRecord
    belongs_to :supplier

    has_many :ordered_stock, class_name: "Spina::Shop::OrderedStock", dependent: :destroy

    scope :concept, -> { where(ordered_at: nil) }
    scope :incoming, -> { where(received_at: nil) }

    def concept?
      ordered_at.blank?
    end

    def ordered?
      ordered_at.present?
    end

    def received?
      received_at.present?
    end

    def place_order!
      self[:ordered_at] = Time.zone.now
      save
    end

    def status
      if ordered?
        if received?
          'received'
        else
          if expected_delivery == Date.today
            'expected_today'
          elsif expected_delivery.present? && expected_delivery < Date.today
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