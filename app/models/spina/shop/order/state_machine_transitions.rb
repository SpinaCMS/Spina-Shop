module Spina::Shop
  module Order::StateMachineTransitions
    extend ActiveSupport::Concern
  
    included do
      include Statesman::Adapters::ActiveRecordQueries[transition_class: OrderTransition, initial_state: :building]
  
      delegate :can_transition_to?, :allowed_transitions, :history, :in_state?, :last_transition, :transition_to!, :transition_to, :current_state, to: :state_machine
    end

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

    def refunded?
      refunded_at.present?
    end

    def paid?
      paid_at.present?
    end
    
    def prepared?
      order_prepared?
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

    def ready_for_pickup?
      current_state == 'ready_for_pickup'
    end
    
    def ready_for_shipment?
      current_state == 'ready_for_shipment'
    end

    def status_progress
      if delivered? || picked_up? || refunded?
        100
      elsif shipped? || ready_for_pickup?
        80
      elsif ready_for_shipment?
        70
      elsif order_prepared?
        60
      elsif paid? || (received? && payment_method == 'postpay')
        40
      elsif received?
        20
      else
        0
      end
    end

    def status_css_class
      if current_state.in? %w(failed cancelled)
        'danger'
      elsif current_state == "refunded"
        'info'
      else
        case status_progress
        when 100
          'success'
        when 80
          'success'
        when 70
          'primary'
        when 60
          'primary'
        when 40
          'primary'
        when 20
          if payment_method == 'postpay'
            'primary'
          else
            ''
          end
        else
          ''
        end
      end
    end

    def transitions_done
      order_transitions.where.not(to_state: %w(confirming failed cancelled refunded))
    end

    def admin_transitions_done
      transitions_done.pluck(:to_state)
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
        if shipped?
          ["received", "paid", "preparing", "shipped", "delivered"]
        else
          ["received", "paid", "preparing", "ready_for_shipment", "shipped", "delivered"]
        end
      else
        if pos?
          ["received", "paid", "picked_up"]
        else
          ["received", "paid", "preparing", "ready_for_pickup", "picked_up"]
        end
      end
    end

    def state_machine
      @state_machine ||= OrderStateMachine.new(self, transition_class: OrderTransition, association_name: :order_transitions)
    end

    def self.transition_name
      :order_transitions
    end

  end
end