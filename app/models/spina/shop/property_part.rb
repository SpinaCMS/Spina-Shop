module Spina::Shop
  class PropertyPart < ApplicationRecord
    def convert_to_json!
      part = Spina::Parts::Line.new
      part.content = content
      part
    end
  end
end