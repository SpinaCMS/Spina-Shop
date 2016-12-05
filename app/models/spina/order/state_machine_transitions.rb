module Spina
  class Order < ApplicationRecord
    include Statesman::Adapters::ActiveRecordQueries

    delegate :can_transition_to?, :allowed_transitions, :history, :in_state?, :last_transition, :transition_to!, :transition_to, :current_state, to: :state_machine

    def received?
      received_at.present?
    end

    def building?
      current_state == 'building'
    end

    def confirming?
      current_state == 'confirming'
    end
    alias_method :confirmed?, :confirming?

    def status_label
      case current_state
      when 'received'
        'Bestelling'
      when 'paid'
        'Betaald'
      when 'order_picking'
        'Voorbereiding'
      when 'shipped'
        'Verzonden'
      when 'delivered'
        'Geleverd'
      when 'failed'
        'Mislukt'
      when 'refunded'
        'Terugbetaald'
      when 'cancelled'
        'Geannuleerd'
      end
    end

    def status_progress
      if delivered_at.present?
        100
      elsif shipped_at.present?
        80
      elsif order_picked_at.present?
        60
      elsif paid_at.present?
        40
      elsif received_at.present? 
        20
      elsif failed_at.present?
        20
      else
        0
      end
    end

    def status_css_class
      case current_state
      when 'order_picking'
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