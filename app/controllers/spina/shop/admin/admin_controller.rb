module Spina
  module Shop
    module Admin
      class AdminController < ::Spina::Admin::AdminController
        include Turbo::Redirection
        
        admin_section :shop
      end
    end
  end
end