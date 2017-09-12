namespace :spina_shop do
  task import_countries: :environment do
    Spina::Shop::CountryImporter.import
  end

  task calculate_trend: :environment do
    products = Spina::Shop::Product.where(stock_enabled: true)
    products.each do |product|
      adjustments = product.stock_level_adjustments.sales.where('spina_shop_stock_level_adjustments.created_at > ?', 90.days.ago).order(:created_at)

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
