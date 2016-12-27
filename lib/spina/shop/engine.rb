module Spina
  module Shop
    class Engine < ::Rails::Engine
      isolate_namespace Spina
      
      config.autoload_paths += %W( #{config.root}/state_machines)
    end
  end
end
