module Spina
  module Shop
    module ViewHelpers

      def to_process_order_count
        @to_process_order_count ||= Spina::Order.in_state(:paid, :order_picking).count
      end

    end
  end
end