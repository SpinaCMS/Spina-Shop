require 'tailwindcss-rails'

SPINA_SHOP_TAILWIND_COMPILE_COMMAND = "#{Tailwindcss::Engine.root.join("exe/tailwindcss")} -i #{Spina::Shop::Engine.root.join("app/assets/stylesheets/spina/shop/application.tailwind.css")} -o #{Rails.root.join("app/assets/builds", "spina/shop/tailwind.css")} -c #{Rails.root.join("app/assets/config/spina/shop/tailwind.config.js")}"

namespace :spina do
  namespace :shop do
    namespace :tailwind do
    
      task :build do
        Rails::Generators.invoke("spina:shop:tailwind_config", ["--force"])
        system SPINA_SHOP_TAILWIND_COMPILE_COMMAND
      end
      
      task :watch do
        Rails::Generators.invoke("spina:shop:tailwind_config", ["--force"])
        system "#{SPINA_SHOP_TAILWIND_COMPILE_COMMAND} -w"
      end
    
    end  
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["spina:shop:tailwind:build"])
end 