require "spina/shop/engine"
require 'spina/shop/railtie' if defined?(Rails)

module Spina
  module Shop
    include ActiveSupport::Configurable

    config_accessor :default_tax_rate, :default_tax_code

    # Default tax settings
    self.default_tax_rate = BigDecimal(0)
    self.default_tax_code = "0"

    self.default_sales_category_code = "8000"

    class << self

      def root
        File.expand_path('../../../', __FILE__)
      end

    end
  end
end