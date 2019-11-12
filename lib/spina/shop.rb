require "spina/shop/engine"
require 'spina/shop/railtie' if defined?(Rails)

module Spina
  module Shop
    include ActiveSupport::Configurable

    config_accessor :default_tax_rate, :default_tax_code, :default_sales_category_code, :payment_methods_for_manual_orders, :invoice_payment_term

    # Default tax settings
    self.default_tax_rate = BigDecimal(0)
    self.default_tax_code = "0"

    # Period to calculate the due date on an invoice
    self.invoice_payment_term = 30.days

    # Manual payment methods are payment methods
    # that can be set when creating an order manually through Spina
    self.payment_methods_for_manual_orders = []

    self.default_sales_category_code = "8000"

    class << self

      def root
        File.expand_path('../../../', __FILE__)
      end

    end
  end
end