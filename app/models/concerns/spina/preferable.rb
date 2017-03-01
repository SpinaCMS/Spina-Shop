require 'active_support/concern'

module Spina
  module Preferable
    extend ActiveSupport::Concern

    included do
      serialize :preferences
    end

    class_methods do
      def preferences(*args)
        args.each do |method_name|
          define_method method_name do
            self.preferences.try(:[], method_name.to_sym)
          end

          define_method "#{method_name}=" do |value|
            self.preferences ||= {}
            self.preferences[method_name.to_sym] = value
          end
        end
      end
    end

  end
end