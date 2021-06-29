json.array! @products do |product|
  json.id product.id
  json.full_name product.full_name
  json.name product.name
  json.variant_name product.variant_name
  json.stock_level product.stock_level
  json.location product.location
  json.ean product.ean
end