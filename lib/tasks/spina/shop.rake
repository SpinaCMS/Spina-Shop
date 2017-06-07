namespace :spina_shop do
  task import_countries: :environment do
    Spina::Shop::CountryImporter.import
  end
end
