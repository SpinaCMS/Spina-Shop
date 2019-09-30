module Spina::Shop
  class StockOrder < ApplicationRecord
    belongs_to :supplier

    has_many :ordered_stock, class_name: "Spina::Shop::OrderedStock", dependent: :restrict_with_exception

    scope :concept, -> { where(ordered_at: nil) }
    scope :open, -> { where(closed_at: nil).where.not(ordered_at: nil) }
    scope :active, -> { where(closed_at: nil).joins(:supplier).order("CASE WHEN ordered_at IS NOT NULL THEN 1 ELSE 0 END", "CASE WHEN expected_delivery IS NOT NULL THEN expected_delivery ELSE ordered_at + (interval '1' day * lead_time) END", created_at: :desc) }
    scope :ordered, -> { where.not(ordered_at: nil) }
    scope :closed, -> { where.not(closed_at: nil) }
    scope :expected_today, -> { where(expected_delivery: Date.today) }

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

    def order_value
      ordered_stock.joins(:product).sum("quantity * cost_price")
    end

    def received_percentage
      "#{((ordered_stock.sum(:received) / ordered_stock.sum(:quantity).to_d) * 100).round}%"
    end

    def place_order!
      return if ordered_stock.none?
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
          elsif ordered_at + supplier.lead_time.days == Date.today
            'expected_today'
          elsif ordered_at + supplier.lead_time.days < Date.today
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
      when 'open'
        ''
      when 'expected_today'
        'primary'
      when 'late'
        'warning'
      end
    end
  end
end