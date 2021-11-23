namespace :spina_shop do
  
  task import_countries: :environment do
    Spina::Shop::CountryImporter.import
  end
  
  task cache_product_statistics: :environment do
    products = Spina::Shop::Product.purchasable.active
    bar = ProgressBar.create title: "Products", total: products.size
    
    products.each do |product|
      product.update_columns(
        statistics_weekly_sales: product.weekly_sales_mean,
        statistics_eoq: product.eoq,
        statistics_reorder_point: product.reorder_point,
        statistics_safety_stock: product.safety_stock
      )
      bar.increment
    end
  end
  
  task xyz_analysis: :environment do
    date_range = 1.year.ago..Date.today
    
    products = Spina::Shop::Product.active
      .joins(order_items: :order)
      .where(spina_shop_orders: {paid_at: date_range})
      
    stale_products = Spina::Shop::Product.active.where.not(id: products.ids)
    stale_products.update_all(xyz_analysis: :z)
    
    products = products.group("orderable_type, orderable_id").count    
    products = products.sort_by(&:last).reverse

    total_order_items = BigDecimal(products.map(&:last).reduce(&:+))
    
    cumulative_percentage = 0
    products.each do |product_id, order_item_count|
      percentage = (order_item_count / total_order_items * 100)
      cumulative_percentage = percentage + cumulative_percentage
      analysis = if cumulative_percentage <= 80
        :x
      elsif cumulative_percentage <= 95
        :y
      else
        :z
      end
      Spina::Shop::Product.where(id: product_id).update_all(xyz_analysis: analysis)
    end
  end
  
  task abc_analysis: :environment do
    date_range = 1.year.ago..Date.today
    
    products = Spina::Shop::Product.active
      .joins(order_items: :order)
      .where(spina_shop_orders: {paid_at: date_range})
    
    # Set stale products to C
    stale_products = Spina::Shop::Product.active.where.not(id: products.ids)
    stale_products.update_all(abc_analysis: :c)
      
    products = products.group("orderable_type, orderable_id").sum("CASE WHEN prices_include_tax = true THEN 
              (unit_price * quantity - discount_amount) / ((tax_rate + 100) / 100.0) 
            ELSE 
              unit_price * quantity - discount_amount 
            END")
      
    products = products.sort_by(&:last).reverse
    
    total_revenue = products.map(&:last).reduce(&:+)
    cumulative_percentage = 0
    
    products.each do |product_id, revenue|
      percentage = (revenue / total_revenue * 100)
      cumulative_percentage = percentage + cumulative_percentage
      analysis = if cumulative_percentage <= 80
        :a
      elsif cumulative_percentage <= 95
        :b
      else
        :c
      end
      Spina::Shop::Product.where(id: product_id).update_all(abc_analysis: analysis)
    end
  end

  task calculate_trend: :environment do
    products = Spina::Shop::Product.where(stock_enabled: true)
    products.each do |product|
      adjustments = product.stock_level_adjustments.sales.where('spina_shop_stock_level_adjustments.created_at > ?', 90.days.ago).order(:created_at)
      # 
      # sum_array = []
      # (-90..0).each.with_index do |day, index|
      #   sales = product.stock_level_adjustments.sales.where('DATE(spina_shop_stock_level_adjustments.created_at) = ?', (day * -1).days.ago).sum(:adjustment) * -1
      #   
      #   sum_array << [index, sales]
      # end
      # 
      # sum_array
      # 

      if adjustments.any?
        total = 0
        first_date = adjustments.first.created_at.to_date

        sum_array = adjustments.map do |adjustment|
          total += adjustment.adjustment * -1
          [(adjustment.created_at.to_date - first_date).to_i, total]
        end

        r = Spina::Shop::SimpleLinearRegression.new(sum_array.map(&:first), sum_array.map(&:last))

        unless r.slope.nan?
          product.update_column(:trend, r.slope)
        else
          product.update_column(:trend, 0)
        end
      else
        product.update_column(:trend, 0)
      end
    end
  end
end
