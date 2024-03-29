module Spina::Shop
  class BatchOrderTransitionJob < Spina::ApplicationJob
    
    # Transition large batches of orders in a bg job
    # States can be an array
    def perform(order_ids, states, user: "Spina CMS", ip_address: nil)
      orders = Order.where(id: order_ids)
      states = states.is_a?(Array) ? states : [states]
      
      orders.each do |order|
        states.each do |state|
          order.transition_to(state, user: user, ip_address: ip_address)
        end
      end
    end
    
  end
end
