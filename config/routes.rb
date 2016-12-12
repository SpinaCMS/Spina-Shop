Spina::Engine.routes.draw do
  # Admin routes
  namespace :admin, path: Spina.config.backend_path do
    # Orders
    resources :orders do
      collection do
        get :to_process
        get :failed
        put :transition
      end
      scope module: :orders do
        resource :packing_slip, only: [:show, :create]
        resource :shipping_label, only: [:show, :create]
      end
    end

    # Settings
    namespace :settings do
      resources :tax_groups
    end

    # Invoices
    resources :invoices, only: [:show]

    # Products
    resources :products do
      get :new_by_category, on: :collection
      scope module: :products do
        resources :product_items do
          resources :stock_level_adjustments
        end
      end
    end
    scope module: :products do
      resources :product_bundles
    end

    # Customers
    resources :customers do
      resource :customer_account
    end

    # Campaigns
    resources :campaigns
  end
end
