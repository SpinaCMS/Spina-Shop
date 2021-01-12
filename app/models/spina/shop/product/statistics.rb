require 'descriptive_statistics'

module Spina::Shop
  module Product::Statistics
    extend ActiveSupport::Concern
    
    def weekly_sales_mean
      sales_per_week.values.mean
    end
    
    def weekly_sales_standard_deviation
      sales_per_week.values.standard_deviation
    end
    
    def daily_sales_mean
      weekly_sales_mean / BigDecimal(7)
    end
    
    def daily_sales_standard_deviation
      weekly_sales_standard_deviation / BigDecimal(7)
    end
    
    # At least 3 days
    def lead_time
      [supplier.lead_time, 3].max
    end
    
    # Should be calculated
    def lead_time_standard_deviation
      2
    end
    
    def lead_time_demand
      daily_sales_mean * lead_time
    end
    
    def lead_time_demand_standard_deviation
      daily_sales_standard_deviation * lead_time_standard_deviation
    end
    
    def safety_stock
      (Math.sqrt(
        weekly_sales_standard_deviation**2 * lead_time / BigDecimal(7) +
        (lead_time_standard_deviation / BigDecimal(7))**2 * weekly_sales_mean**2
      ) * z_score).round
    end
    
    def reorder_point
      lead_time_demand.round + safety_stock
    end

    # Default Z-score – 99.98%
    def z_score
      BigDecimal("3.49")
    end
    
    # Returns a hash of sales per week (max. 53 weeks)
    def sales_per_week
      return @sales_per_week if @sales_per_week.present?
      first_sale = stock_level_adjustments.sales.order(:created_at).first
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