Spina::Engine.routes.draw do
  # Admin routes
  namespace :shop, path: '' do

    # Admin panel
    namespace :admin, path: Spina.config.backend_path do
      scope '/shop' do
        # Orders
        resources :orders do
          resources :order_items, only: [:new, :create, :destroy]
          member do
            post :confirm
            post :cancel
            post :pay
            post :receive
            post :order_picked_up
            post :delivered
          end
          collection do
            get :to_process
            get :failed
          end
          scope module: :orders do
            resource :packing_slip, only: [:show, :create]
            resource :shipping_label, only: [:show, :create]
          end
        end

        namespace :orders do
          resource :batch, only: [:create]
        end

        # Settings
        namespace :settings do
          resources :tax_groups
          resources :sales_categories
          resources :shared_properties
          resources :product_categories do
            resources :product_category_properties do
              member do
                get :edit_options
              end
            end
          end
          resources :tags
        end

        # Invoices
        resources :invoices

        # Products
        namespace :products do
          resource :batch, only: [:edit, :update]
        end

        resources :products do
          collection do
            get :archived
          end
          member do
            get 'translations/:field', to: 'products#translations', as: :translations
            get :duplicate
            get :variant
            post :archive
            post :unarchive
          end
          get :new_by_category, on: :collection
          scope module: :products do
            resources :in_stock_reminders
            resources :stock_level_adjustments
          end
        end
        scope module: :products do
          resources :product_bundles do
            collection do
              get :archived
            end
            member do
              post :archive
              post :unarchive
            end
          end
        end

        scope module: :stock do
          resource :stock_forecast
          resources :suppliers
          resources :stock_orders do
            member do
              post :place_order
              post :reopen_order
              post :close_order
            end
            resources :ordered_stock, only: [:destroy]
            resource :receive_products, only: [:new, :create]
          end
          resource :stock_order_products, only: [:new, :create]
        end

        # Product reviews
        resources :shop_reviews do
          collection do
            post :batch_update
          end
        end
        resources :product_reviews do
          collection do
            delete :delete_multiple
          end
        end

        # Customers
        resources :customer_groups
        resources :customers do
          member do
            get :validate_vat_id
          end
          resource :customer_account
        end

        # Discounts
        resources :discounts

        # Reports
        resources :reports
        resource :analytics
        resources :exports

        # Gift Cards
        resources :gift_cards do
          collection do
            get :unused
          end
        end
      end
    end

    # Stock Management
    namespace :stock_management, path: '/admin/stockapp' do
      root 'dashboard#show'

      get :login, to: 'sessions#new'
      post :login, to: 'sessions#create', as: 'post_login'
      get :logout, to: 'sessions#destroy'

      resources :locations

      resources :stock_orders do
        member do
          post :close_order
        end
        resource :receive_products, only: [:new, :create]
      end

      resources :products do
        collection do
          get :search
        end
        resource :recount, only: [:new, :create]
      end
    end
  end
end