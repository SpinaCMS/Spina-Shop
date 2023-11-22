module Spina::Shop
  class BatchOrderTransitionJob < ApplicationJob
    
    # Transition large batches of orders in a bg job
    # States can be an array
    def perform(order_ids, states, user: "Spina CMS", ip_address: nil)
      orders = Order.where(id: order_ids)
      states = state.is_a?(Array) ? states : [state]
      
      orders.each do |order|
        states.each do |state|
          order.transition_to(state, user: user, ip_address: ip_address)
        end
      end
    end
    
  end
end
