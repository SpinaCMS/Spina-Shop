require 'descriptive_statistics'

module Spina::Shop
  module Product::Statistics
    extend ActiveSupport::Concern
    
    included do
      enum abc_analysis: {a: 0, b: 1, c: 2}
    end
    
    def weekly_sales_mean
      return 0 if sales_per_week.blank?
      sales_per_week.values.mean
    end
    
    def weekly_sales_standard_deviation
      return 0 if sales_per_week.blank?
      sales_per_week.values.standard_deviation
    end
    
    def daily_sales_mean
      weekly_sales_mean / BigDecimal(7)
    end
    
    def daily_sales_standard_deviation
      weekly_sales_standard_deviation / BigDecimal(7)
    end
    
    def lead_time_demand
      daily_sales_mean * supplier&.lead_time.to_i
    end
    
    def lead_time_demand_standard_deviation
      daily_sales_standard_deviation * supplier&.lead_time_standard_deviation.to_i
    end
    
    def max_stock
      eoq + reorder_point
    end
    
    def safety_stock
      (Math.sqrt(
        weekly_sales_standard_deviation**2 * supplier&.lead_time.to_i / BigDecimal(7) +
        (supplier&.lead_time_standard_deviation.to_i / BigDecimal(7))**2 * weekly_sales_mean**2
      ) * z_score).round
    end
    
    def holding_cost
      (cost_price || 0) * (Spina::Shop.config.holding_cost_percentage / BigDecimal(100))
    end
    
    def stock_order_cost
      supplier&.average_stock_order_cost || Spina::Shop.config.default_stock_order_cost
    end
    
    # Economic order quantity
    def eoq
      return 0 if holding_cost.zero?
      Math.sqrt(
        (2 * weekly_sales_mean * 52 * stock_order_cost) /
        holding_cost
      ).round
    end
    
    def reorder_point
      lead_time_demand.round + safety_stock
    end
    
    def service_level
      case abc_analysis
      when "a"
        "99,97%"
      when "b"
        "99%"
      when "c"
        "97,7%"        
      end
    end

    # Z-score based on ABC-analysis
    # A – 99,97% = 3,4
    # B - 99% = 2,4
    # C - 97,7% = 2,0
    def z_score
      case abc_analysis
      when "a"
        BigDecimal("3.4")
      when "b"
        BigDecimal("2.4")
      when "c"
        BigDecimal("2")
      else
        BigDecimal("1")
      end
    end
    
    # Returns a hash of sales per week (max. 53 weeks)
    def sales_per_week
      return @sales_per_week if @sales_per_week.present?
      first_sale = stock_level_adjustments.sales.order(:created_at).first
      return {} unless first_sale.present?
      days_since_first_sale = (Date.today - first_sale.created_at.to_date).to_i
      weeks_since_first_sale = days_since_first_sale / 7
      
      sales_per_yearweek = stock_level_adjustments.sales
        .group("EXTRACT('isoyear' from created_at)::TEXT || LPAD(EXTRACT('week' from created_at)::TEXT, 2, '0')")
        .sum(:adjustment).sort_by{|key,value| key}.to_h
      
      weeks_ago = [53, weeks_since_first_sale].min
      @sales_per_week = weeks_ago.downto(1).map do |week|
        yearweek = date_to_yearweek(Date.today - week.weeks)
        sales = sales_per_yearweek[yearweek].to_i * -1
        [yearweek, sales]
      end.to_h
    end
    
    private
    
      def date_to_yearweek(date)
        year = date.cwyear
        week = date.cweek.to_s.rjust(2, "0")
        "#{year}#{week}"
      end
    
  end
end