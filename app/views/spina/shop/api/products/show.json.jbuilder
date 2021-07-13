json.(@product, :id, :ean, :stock_level, :location, :expiration_date)
json.full_name @product.full_name
json.name @product.name
json.variant_name @product.variant_name
json.description @product.description
json.properties @product.properties
json.locations @product.product_locations.joins(:location).where(spina_shop_locations: {primary: false}) do |location|
  json.name location.location.name
  json.location_code location.location_code.to_s
  json.stock_level location.stock_level
end