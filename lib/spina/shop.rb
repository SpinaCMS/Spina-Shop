require "spina/shop/engine"
require 'spina/shop/railtie' if defined?(Rails)

module Spina
  module Shop
    include ActiveSupport::Configurable

    class << self

      def root
        File.expand_path('../../../', __FILE__)
      end

    end
  end
end