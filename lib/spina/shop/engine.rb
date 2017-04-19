require 'statesman'
require 'kaminari'
require 'select2-rails'
require 'delocalize'
require 'prawn'
require 'bcrypt'
require 'email_validator'
require 'ransack'
require 'kaminari'
require 'pg_search'

module Spina
  module Shop
    class Engine < ::Rails::Engine
      isolate_namespace Spina

      config.autoload_paths += %W(#{config.root}/state_machines)
    end
  end
end
