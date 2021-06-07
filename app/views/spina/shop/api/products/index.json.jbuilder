json.array! @products do |product|
  json.id product.id
  json.name product.name
  json.stock_level product.stock_level
  json.location product.location
  json.ean product.ean
end