module Spina::Shop
  module Admin
    module Stock
      class StockForecastsController < AdminController
        layout 'spina/shop/admin/stock'

        def show
          add_breadcrumb "Voorraad"

          @unique_locations ||= Spina::Shop::Product.active.where.not(location: "").pluck('location').uniq.compact.sort
          @locations = @unique_locations.map do |location|
            regex = location.match(/\A(\d*)([a-zA-Z]*).*\z/)
            regex.try(:[], 1).presence || regex.try(:[], 2).presence
          end.uniq.compact.sort_by do |location|
            location.length > 2 ? '1' : '0' + location
          end

          products = Product.joins("LEFT JOIN spina_shop_suppliers ON spina_shop_products.supplier_id = spina_shop_suppliers.id").where(stock_enabled: true, archived: false).joins(:translations).order("#{params[:order]} #{params[:direction]}").where(spina_shop_product_translations: {locale: I18n.locale}).group("spina_shop_products.id, spina_shop_product_translations.id")
          
          if params[:order] == "statistics_safety_stock"
            products = products.reorder(Arel.sql("CASE WHEN stock_level - statistics_safety_stock < 0 THEN stock_level - statistics_safety_stock ELSE 1 END, CASE WHEN stock_level - statistics_reorder_point < 0 THEN stock_level - statistics_reorder_point ELSE 1 END"))
            products = products.where(available_at_supplier: true).where('statistics_reorder_point > 0')
          end
          
          @q = products.ransack(params[:q])
          
          @products = @q.result.page(params[:page]).per(50)

          respond_to do |format|
            format.js
            format.html
            format.csv do
              data = CSV.generate do |csv|
                # csv << %w(ID Product Locatie Lopen30 Lopen90 Lopen365 Verkoop30 Verkoop90 Verkoop365 Trend Voorraad Optimale\ voorraad Voorraadverschil Doorlooptijd Herinneren Verkoopprijs Kostprijs Voorraadwaarde)
                
                csv << %w(ID Product Locatie Formaat Inhoud Lopen30 Verkoop30 Wekelijkse\ verkoop Voorraad Max\ Voorraad Veiligheidsvoorraad Bestelpunt EOQ Inkooporders\ per\ jaar Leverancier Categorie Verpakkingseenheid Laatste\ hertelling THT Uitlopend)
                
                @products = @q.result.page(params[:page]).per(5000)
                
                @products.each.each do |product|
                  recount = product.recounts.order(created_at: :desc).first
                  
                  csv << [product.id, 
                    product.full_name, 
                    product.location, 
                    product.dimensions,
                    product.volume,
                    product.order_items.joins(:order).where(spina_shop_orders: {paid_at: 30.days.ago..Date.today}).count,
                    product.stock_level_adjustments.sales.where(spina_shop_stock_level_adjustments: {created_at: 30.days.ago..Date.today}).sum(:adjustment) * -1,
                    product.statistics_weekly_sales,
                    product.stock_level,
                    product.statistics_max_stock,
                    product.statistics_safety_stock,
                    product.statistics_reorder_point,
                    product.statistics_eoq,
                    product.stock_orders_per_year,
                    product.supplier&.name,
                    product.product_category&.name,
                    product.supplier_packing_unit,
                    recount ? I18n.l(recount.created_at, format: "%d-%m-%Y") : "",
                    product.can_expire? && product.expiration_date ? I18n.l(product.expiration_date, format: "%m-%Y") : "",
                    product.available_at_supplier? ? "" : "Uitlopend"
                  ]
                end
              end
              
              send_data data, filename: "voorraad.csv", disposition: "attachment"
            end
          end
        end

      end
    end
  end
end