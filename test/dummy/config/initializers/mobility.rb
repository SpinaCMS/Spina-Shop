Mobility.configure do |config|
  config.default_backend = :table
  config.accessor_method = :translates
  config.query_method    = :i18n
  config.default_options[:dirty] = true
  config.default_options[:locale_accessors] = true
  # config.default_options[:fallbacks] = {
  #   'en' => ['en'],
  #   'de' => ['de'],
  #   'nl' => ['nl'],
  #   'de-eliquid' => ['de-eliquid', 'de'],
  #   'de-diamond' => ['de-diamond', 'de'],
  #   'en-diamond' => ['en-diamond', 'en'],
  #   'nl-eliquid' => ['nl-eliquid', 'nl'],
  #   'nl-diamond' => ['nl-diamond', 'nl']
  # }
end
