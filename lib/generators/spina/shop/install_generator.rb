module Spina
  module Shop
    class InstallGenerator < Rails::Generators::Base

      def copy_migrations
        return if Rails.env.production?
        rake 'spina_shop:install:migrations'
      end

      def run_migrations
        rake 'db:migrate'
      end

      def import_countries
        rake 'spina_shop:import_countries'
      end

      def default_product_category
        default_product_category = Spina::Shop::ProductCategory.where(name: 'Default').first_or_initialize
        default_product_category.save
      end

      def default_tax_group
        default_tax_group = Spina::Shop::TaxGroup.where(name: "Standard VAT").first_or_initialize
        default_tax_group.tax_rates = {
          world: {
            default: {
              rate: 20.0,
              tax_code: "0"
            }
          }
        }
        default_tax_group.save
      end

      def default_sales_category
        default_sales_category = Spina::Shop::SalesCategory.where(name: "Default").first_or_initialize
        default_sales_category.codes = {
          world: {
            default: "0"
          }
        }
        default_sales_category.save
      end

      def feedback
        puts
        puts '    Your Spina Shop has been succesfully installed! '
        puts
        puts '    Restart your server and visit http://localhost:3000 in your browser!'
        puts "    The admin backend is located at http://localhost:3000/#{Spina.config.backend_path}."
        puts
      end

    end
  end
end