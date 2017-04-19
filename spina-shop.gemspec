$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spina/shop/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spina-shop"
  s.version     = Spina::Shop::VERSION
  s.authors     = ["Bram Jetten"]
  s.email       = ["mail@bramjetten.nl"]
  s.homepage    = "https://www.spinacms.com"
  s.summary     = "Spina eCommerce"
  s.description = "Building webshops with Spina"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"
  s.add_dependency "statesman"
  s.add_dependency "select2-rails"
  s.add_dependency "delocalize"
  s.add_dependency "prawn"
  s.add_dependency "prawn-table"
  s.add_dependency "bcrypt"
  s.add_dependency "email_validator"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
  s.add_dependency "pg_search"

  s.add_development_dependency "sqlite3"
end
