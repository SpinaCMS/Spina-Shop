json.(@product, :id, :ean, :stock_level, :location, :expiration_date)
json.name @product.name
json.description @product.description
json.properties @product.properties
json.locations @product.product_locations do |location|
  json.name location.location.name
  json.location_code location.location_code
end