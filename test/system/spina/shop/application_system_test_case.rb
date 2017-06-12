require "test_helper"

module Spina::Shop
  class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end
end