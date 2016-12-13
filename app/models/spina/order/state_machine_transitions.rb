module Spina
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

    def order_picked?
      order_picked_at.present?
    end

    def shipped?
      shipped_at.present?
    end

    def delivered?
      delivered_at.present?
    end

    def building?
      current_state == 'building'
    end

    def confirming?
      current_state == 'confirming'
    end

    def status_progress
      if delivered?
        100
      elsif shipped?
        80
      elsif order_picked?
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
      case current_state
      when 'order_picking'
        'primary'
      when 'paid'
        'primary'
      when 'shipped'
        'success'
      when 'delivered'
        'success'
      when 'failed'
        'danger'
      when 'cancelled'
        'danger'
      else
        ''
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