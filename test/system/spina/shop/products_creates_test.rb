require "application_system_test_case"

module Spina::Shop
  class ProductsCreatesTest < ApplicationSystemTestCase

    test "visiting the admin login" do
      visit spina.admin_login_url
      assert_selector "button", text: "Login"
    end

  end
end