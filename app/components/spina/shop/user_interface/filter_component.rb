module Spina::Shop
  module UserInterface
    class FilterComponent < ApplicationComponent
      attr_reader :label, :name, :options, :f
      attr_reader :radio
      
      def initialize(f, label, name, options, radio: false)
        @f, @label, @name, @options = f, label, name, options
        @radio = radio
      end
      
      def render?
        options.any?
      end
      
    end
  end
end