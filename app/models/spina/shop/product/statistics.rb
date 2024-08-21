require 'descriptive_statistics/safe'

# This Ruby class within Spina::Shop as Product::Statistics is a
# concern in Ruby on Rails, encapsulating statistical methods for a
# Product class. It's aimed at e-commerce management.
# 
# Enums for ABC and XYZ Analysis: Defines enums for abc_analysis
# and xyz_analysis, used in inventory categorization.
# 
# Weekly Sales Mean/Std Deviation: Calculates average and
# variability of weekly sales.
# 
# Future Yearly Demand: Estimates annual demand based on weekly
# sales and a demand factor.
# 
# Daily Sales Mean/Std Deviation: Provides daily sales trends.
# 
# Lead Time Demand/Std Deviation: Estimates demand and variability
# during supplier lead time.
# 
# Max Stock and Safety Stock: Calculates maximum stock level and
# safety stock, using weekly sales data, lead time, and a z-score.
# 
# Holding/Stock Order Cost: Computes inventory holding cost and
# order cost, varying with XYZ analysis category.
# 
# Economic Order Quantity (EOQ): Calculates EOQ to minimize total
# inventory costs.
# 
# Stock Orders Per Year/Reorder Point: Determines yearly stock
# orders and inventory reorder point.
# 
# Service Level and Z-Score: Determines service level based on
# ABC and XYZ analysis, and calculates the corresponding z-score.
# 
# Sales Per Week: Calculates weekly sales, grouping data by week
# and year.
# 
# This concern adds inventory management functionality, including sales
# analysis, demand forecasting, and key inventory metrics calculations.
module Spina::Shop
  module Product::Statistics
    extend ActiveSupport::Concern
    
    included do
      enum abc_analysis: {a: 0, b: 1, c: 2}
      enum xyz_analysis: {x: 0, y: 1, z: 2}
    end
    
    def weekly_sales_mean
      return 0 if sales_per_week.blank?
      DescriptiveStatistics::Stats.new(sales_per_week.values).mean
    end
    
    def weekly_sales_standard_deviation
      return 0 if sales_per_week.blank?
      DescriptiveStatistics::Stats.new(sales_per_week.values).standard_deviation
    end
    
    def future_yearly_demand
      weekly_sales_mean * 52 * Spina::Shop.config.future_demand_factor
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
    
    def statistics_max_stock
      statistics_eoq + statistics_reorder_point
    end
    
    def safety_stock
      (Math.sqrt(
        weekly_sales_standard_deviation**2 * supplier&.lead_time.to_i / BigDecimal(7) +
        (supplier&.lead_time_standard_deviation.to_i / BigDecimal(7))**2 * weekly_sales_mean**2
      ) * z_score).round
    end
    
    def holding_cost
      holding_cost_percentage = case xyz_analysis
      when "x"
        50
      when "y"
        75
      when "z"
        100
      else
        Spina::Shop.config.holding_cost_percentage
      end
      
      (cost_price || 0) * (holding_cost_percentage / BigDecimal(100))
    end
    
    def stock_order_cost
      supplier&.average_stock_order_cost || Spina::Shop.config.default_stock_order_cost
    end
    
    # Economic order quantity
    def eoq
      return 0 if holding_cost.zero?
      Math.sqrt(
        (2 * future_yearly_demand * stock_order_cost) /
        holding_cost
      ).round
    end
    
    def stock_orders_per_year
      return 0 if eoq.zero?
      (future_yearly_demand / eoq).ceil
    end
    
    def reorder_point
      lead_time_demand.round + safety_stock
    end
    
    def service_level
      case abc_analysis.to_s + xyz_analysis.to_s
      when "ax"
        98
      when "ay"
        96
      when "az"
        94
      when "bx"
        96
      when "by"
        94
      when "bz"
        92
      when "cx"
        94
      when "cy"
        92
      when "cz"
        90
      end
    end

    # Z-score based on servicelevel
    def z_score
      case service_level
      when 98
        BigDecimal("2.06")
      when 96
        BigDecimal("1.75")
      when 94
        BigDecimal("1.56")
      when 92
        BigDecimal("1.41")
      when 90
        BigDecimal("1.29")
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