module Spina
  module Shop
    module Admin
      class AdminController < ::Spina::Admin::AdminController
        include Turbo::Redirection
      end
    end
  end
end