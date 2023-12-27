require "spina/shop/engine"
require 'spina/shop/railtie' if defined?(Rails)

module Spina
  module Shop
    include ActiveSupport::Configurable

    config_accessor :default_tax_rate, 
                    :default_tax_code, 
                    :default_sales_category_code, 
                    :payment_methods,
                    :payment_methods_for_manual_orders, 
                    :invoice_payment_term, 
                    :refund_methods, 
                    :refund_reasons,
                    :return_reasons,
                    :stock_level_adjustment_categories,
                    :holding_cost_percentage,
                    :default_stock_order_cost,
                    :future_demand_factor,
                    :minimum_expiration_period,
                    :api_key

    # Default tax settings
    self.default_tax_rate = BigDecimal(0)
    self.default_tax_code = "0"

    # Default sales category settings
    self.default_sales_category_code = "8000"

    # Period to calculate the due date on an invoice
    self.invoice_payment_term = 30.days

    # Manual payment methods are payment methods
    # that can be set when creating an order manually through Spina
    self.payment_methods = []
    self.payment_methods_for_manual_orders = []

    # Methods and reasons users can choose for refunds and returns
    self.refund_methods = []
    self.refund_reasons = ['other']
    self.return_reasons = []

    # Categories for manual stock level adjustments
    self.stock_level_adjustment_categories = []
    
    # Holding cost
    self.holding_cost_percentage = 25
    
    # Default stock order cost
    self.default_stock_order_cost = 5
    
    # Minimum expiration period
    # Spina will show a warning when adding items with an expiration period
    # smaller than the one set here
    self.minimum_expiration_period = nil
    
    # Future demand factor
    # Demand calculations are multiplied by this factor to 
    # represent future demand
    # 
    # Example:
    # If you expect the coming year to increase demand by 20%, 
    # set this factor to 1.2
    self.future_demand_factor = 1
    
    # API key for external plugins
    self.api_key = nil

    class << self

      def root
        File.expand_path('../../../', __FILE__)
      end

    end
  end
end