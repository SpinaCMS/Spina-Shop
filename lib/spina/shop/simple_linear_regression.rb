module Spina
  module Shop
    class SimpleLinearRegression
      def initialize(xs, ys)
        @xs, @ys = xs, ys
        if @xs.length != @ys.length
          raise "Unbalanced data. xs need to be same length as ys"
        end
      end

      def y_intercept
        mean(@ys) - (slope * mean(@xs))
      end

      def slope
        x_mean = mean(@xs)
        y_mean = mean(@ys)

        numerator = (0...@xs.length).reduce(0) do |sum, i|
          sum + ((@xs[i] - x_mean) * (@ys[i] - y_mean))
        end

        denominator = @xs.reduce(0) do |sum, x|
          sum + ((x - x_mean) ** 2)
        end

        (numerator / denominator)
      end

      def mean(values)
        total = values.reduce(0) { |sum, x| x + sum }
        Float(total) / Float(values.length)
      end
    end
  end
end