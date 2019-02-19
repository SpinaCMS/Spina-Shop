module Spina::Shop
  class Order < ApplicationRecord
    include Statesman::Adapters::ActiveRecordQueries

    delegate :can_transition_to?, :allowed_transitions, :history, :in_state?, :last_transition, :transition_to!, :transition_to, :current_state, to: :state_machine

    def received?
      received_at.present?
    end

    def failed?
      failed_at.present?
    end

    def cancelled?
      cancelled_at.present?
    end

    def confirmed?
      confirming_at.present?
    end

    def paid?
      paid_at.present?
    end

    def order_prepared?
      order_prepared_at.present?
    end

    def shipped?
      shipped_at.present?
    end

    def delivered?
      delivered_at.present?
    end

    def picked_up?
      picked_up_at.present?
    end

    def building?
      current_state == 'building'
    end

    def confirming?
      current_state == 'confirming'
    end

    def status_progress
      if delivered? || picked_up?
        100
      elsif shipped?
        80
      elsif order_prepared?
        60
      elsif paid?
        40
      elsif received?
        20
      else
        0
      end
    end

    def status_css_class
      return 'success' if delivered? || picked_up?
      case current_state
      when 'preparing'
        'primary'
      when 'paid'
        'primary'
      when 'shipped'
        'success'
      when 'delivered'
        'success'
      when 'picked_up'
        'success'
      when 'failed'
        'danger'
      when 'cancelled'
        'danger'
      else
        ''
      end
    end

    def admin_transitions_done
      order_transitions.pluck(:to_state) - ["confirming", "failed", "cancelled", "refunded"]
    end

    def admin_next_transitions
      transitions = admin_transition_order - admin_transitions_done
      transitions.drop(admin_transitions_ended.size)
    end

    def admin_transitions_ended
      ["failed", "cancelled", "refunded"] & order_transitions.pluck(:to_state)
    end

    def admin_transition_order
      if requires_shipping?
        ["received", "paid", "preparing", "shipped", "delivered"]
      else
        if pos?
          ["received", "paid", "picked_up"]
        else
          ["received", "paid", "preparing", "picked_up"]
        end
      end
    end

    def state_machine
      @state_machine ||= OrderStateMachine.new(self, transition_class: OrderTransition, association_name: :order_transitions)
    end

    def self.transition_name
      :order_transitions
    end

    def self.transition_class
      OrderTransition
    end
    private_class_method :transition_class

    def self.initial_state
      :building
    end
    private_class_method :initial_state
  end
end