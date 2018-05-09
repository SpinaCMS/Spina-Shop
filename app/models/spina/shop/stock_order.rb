module Spina::Shop
  class StockOrder < ApplicationRecord
    belongs_to :supplier

    has_many :ordered_stock, class_name: "Spina::Shop::OrderedStock", dependent: :destroy

    scope :concept, -> { where(ordered_at: nil) }
    scope :open, -> { where(closed_at: nil).where.not(ordered_at: nil) }
    scope :ordered, -> { where.not(ordered_at: nil) }
    scope :closed, -> { where.not(closed_at: nil) }

    def open?
      ordered? && !closed?
    end

    def concept?
      ordered_at.blank?
    end

    def ordered?
      ordered_at.present?
    end

    def closed?
      closed_at.present?
    end

    def place_order!
      self[:ordered_at] = Time.zone.now
      save
    end

    def status
      if ordered?
        if closed?
          'closed'
        else
          if expected_delivery == Date.today
            'expected_today'
          elsif expected_delivery.present? && expected_delivery < Date.today
            'late'
          else
            'open'
          end
        end
      else
        'concept'
      end
    end

    def status_label
      case status
      when 'closed'
        ''
      when 'open'
        'alert'
      when 'expected_today'
        'primary'
      when 'late'
        'danger'
      end
    end
  end
end