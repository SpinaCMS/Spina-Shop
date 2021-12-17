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

  s.add_dependency "rails", ">= 5.2"
  s.add_dependency "spina"
  s.add_dependency "pg"
  s.add_dependency "ransack"
  s.add_dependency "statesman"
  s.add_dependency "email_validator"
  s.add_dependency "delocalize"
  s.add_dependency "prawn-svg"
  s.add_dependency "prawn-table"
  s.add_dependency "prawn"
  s.add_dependency "ruby-measurement"
  s.add_dependency "valvat"
  s.add_dependency "rubyzip"
  s.add_dependency "simple_xlsx_writer"
  s.add_dependency "zip-zip"
  s.add_dependency "rqrcode"
  s.add_dependency "pg_search"
  s.add_dependency "descriptive_statistics"
  s.add_dependency "jbuilder"
  s.add_dependency "view_component"

  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'puma'
end
