module Spina
  class InStockReminderJob < ApplicationJob

    def perform(orderable)
      if orderable.in_stock?
        orderable.in_stock_reminders.pluck(:email).compact.uniq.each do |email|
          InStockReminderMailer.reminder(email, orderable).deliver_later
        end

        # Delete all reminders because we just sent them
        # Efficient but won't trigger callbacks
        orderable.in_stock_reminders.delete_all
      end
    end

  end
end