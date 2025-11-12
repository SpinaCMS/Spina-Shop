# frozen_string_literal: true

module Spina::Shop
  module Admin
    module Stock
      class StockForecastsController < AdminController
        layout 'spina/shop/admin/stock'

        def show
          add_breadcrumb 'Voorraad'

          @unique_locations ||= Spina::Shop::Product.active.where.not(location: '').pluck('location').uniq.compact.sort
          @locations = @unique_locations.map do |location|
            regex = location.match(/\A(\d*)([a-zA-Z]*).*\z/)
            regex.try(:[], 1).presence || regex.try(:[], 2).presence
          end.uniq.compact.sort_by do |location|
            location.length > 2 ? '1' : '0' + location
          end

          products = Product.joins('LEFT JOIN spina_shop_suppliers ON spina_shop_products.supplier_id = spina_shop_suppliers.id').where(stock_enabled: true, archived: false).joins(:translations).order("#{params[:order]} #{params[:direction]}").where(spina_shop_product_translations: {locale: I18n.locale}).group('spina_shop_products.id, spina_shop_product_translations.id')

          if params[:order] == 'statistics_safety_stock'
            products = products.reorder(Arel.sql('CASE WHEN stock_level - statistics_safety_stock < 0 THEN stock_level - statistics_safety_stock ELSE 1 END, CASE WHEN stock_level - statistics_reorder_point < 0 THEN stock_level - statistics_reorder_point ELSE 1 END'))
            products = products.where(available_at_supplier: true).where('statistics_reorder_point > 0')
          end

          @q = products.where('sku ILIKE :search OR location ILIKE :search OR translations_name ILIKE :search OR translations_variant_name ILIKE :search', search: "%#{params[:search]}%")
          @q = @q.where(product_category_id: params[:product_category_id_in]) if params[:product_category_id_in].present?
          @q = @q.where(location: params[:location_start_any]) if params[:location_start_any].present?
          @q = @q.where('recounts_created_at >= :recounts_created_at_gteq', recounts_created_at_gteq: params[:recounts_created_at_gteq]) if params[:recounts_created_at_gteq].present?
          @q = @q.where(supplier_id: params[:supplier_id_in]) if params[:supplier_id_in].present?
          @q = @q.where(available_at_supplier: params[:available_at_supplier_eq]) if params[:available_at_supplier_eq].present?
          @q = @q.where(statistics_weekly_sales: params[:statistics_weekly_sales_eq]) if params[:statistics_weekly_sales_eq].present?

          @products = @q.distinct.limit(50).offset((params[:page].to_i || 1) * 50 - 50)

          respond_to do |format|
            format.js
            format.html
            format.csv do
              data = CSV.generate do |csv|
                # csv << %w(ID Product Locatie Lopen30 Lopen90 Lopen365 Verkoop30 Verkoop90 Verkoop365 Trend Voorraad Optimale\ voorraad Voorraadverschil Doorlooptijd Herinneren Verkoopprijs Kostprijs Voorraadwaarde)

                csv << %w(ID Product EAN Locatie Formaat Inhoud Lopen30 Lopen365 Verkoop30 Verkoop365 Wekelijkse\ verkoop Voorraad Max\ Voorraad Veiligheidsvoorraad Bestelpunt EOQ Inkooporders\ per\ jaar Leverancier Categorie Verpakkingseenheid Laatste\ hertelling THT Uitlopend Verkoopprijs Kostprijs XYZ Kosten\ per\ leveringsorder)

                @products = @q.distinct.limit(5000).offset((params[:page].to_i || 1) * 5000 - 5000)

                @products.each.each do |product|
                  recount = product.recounts.order(created_at: :desc).first

                  csv << [product.id,
                          product.full_name,
                          product.ean,
                          product.location,
                          product.dimensions,
                          product.volume,
                          product.order_items.joins(:order).where(spina_shop_orders: {paid_at: 30.days.ago..Date.today}).count,
                          product.order_items.joins(:order).where(spina_shop_orders: {paid_at: 365.days.ago..Date.today}).count,
                          product.stock_level_adjustments.sales.where(spina_shop_stock_level_adjustments: {created_at: 30.days.ago..Date.today}).sum(:adjustment) * -1,
                          product.stock_level_adjustments.sales.where(spina_shop_stock_level_adjustments: {created_at: 365.days.ago..Date.today}).sum(:adjustment) * -1,
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
                          recount ? I18n.l(recount.created_at, format: '%d-%m-%Y') : '',
                          product.can_expire? && product.expiration_date ? I18n.l(product.expiration_date, format: '%m-%Y') : '',
                          product.available_at_supplier? ? '' : 'Uitlopend',
                          product.base_price,
                          product.cost_price,
                          product.xyz_analysis,
                          product.stock_order_cost
                  ]
                end
              end

              send_data data, filename: 'voorraad.csv', disposition: 'attachment'
            end
          end
        end
      end
    end
  end
end
