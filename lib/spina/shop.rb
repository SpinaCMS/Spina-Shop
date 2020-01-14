require "spina/shop/engine"
require 'spina/shop/railtie' if defined?(Rails)

module Spina
  module Shop
    include ActiveSupport::Configurable

    config_accessor :default_tax_rate, 
                    :default_tax_code, 
                    :default_sales_category_code, 
                    :payment_methods_for_manual_orders, 
                    :invoice_payment_term, 
                    :refund_methods, 
                    :refund_reasons,
                    :stock_level_adjustment_categories

    # Default tax settings
    self.default_tax_rate = BigDecimal(0)
    self.default_tax_code = "0"

    # Default sales category settings
    self.default_sales_category_code = "8000"

    # Period to calculate the due date on an invoice
    self.invoice_payment_term = 30.days

    # Manual payment methods are payment methods
    # that can be set when creating an order manually through Spina
    self.payment_methods_for_manual_orders = []

    # Methods and reasons users can choose for refunds
    self.refund_methods = []
    self.refund_reasons = ['other']

    # Categories for manual stock level adjustments
    self.stock_level_adjustment_categories = []

    class << self

      def root
        File.expand_path('../../../', __FILE__)
      end

    end
  end
end