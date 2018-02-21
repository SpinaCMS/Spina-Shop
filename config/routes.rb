Spina::Engine.routes.draw do
  # Admin routes
  namespace :shop, path: '' do
    namespace :admin, path: Spina.config.backend_path do
      scope '/shop' do
        # Orders
        resources :orders do
          resources :order_items, only: [:new, :create, :destroy]
          member do
            post :cancel
            post :pay
            post :receive
            post :order_picked_up
            post :delivered
          end
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
          resources :sales_categories
          resources :product_categories do
            resources :product_category_properties do
              member do
                get :edit_options
              end
            end
          end
        end

        # Invoices
        resources :invoices, only: [:show]

        # Products
        namespace :products do
          resource :batch, only: [:edit, :update]
        end

        resources :products do
          collection do
            get :archived
          end
          member do
            get :duplicate
            get :variant
            post :archive
            post :unarchive
          end
          get :new_by_category, on: :collection
          scope module: :products do
            resources :stock_level_adjustments
          end
        end
        scope module: :products do
          resource :stock_forecast
          resources :product_bundles
        end

        # Product reviews
        resources :product_reviews do
          collection do
            delete :delete_multiple
          end
        end

        # Customers
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

        # Gift Cards
        resources :gift_cards do
          collection do
            get :unused
          end
        end
      end
    end
  end
end