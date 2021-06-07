module Spina::Shop
  module Product::Search
    extend ActiveSupport::Concern

    included do
      include PgSearch

      has_many :product_translations, foreign_key: :spina_shop_product_id

      pg_search_scope :search, 
        against: [:properties], 
        associated_against: {
          product_translations: :name, 
          tags: :name
        },
        using: {
          tsearch: {prefix: true, any_word: true},
          trigram: {only: [:name], threshold: 0.2}
        },
        ranked_by: "(:trigram) + (:tsearch / 2.0)"
        
      pg_search_scope :search_name,
        associated_against: {
          product_translations: :name
        },
        using: {
          tsearch: {prefix: true, any_word: true},
          trigram: {only: [:name], threshold: 0.2}
        },
        ranked_by: "(:trigram) + (:tsearch / 2.0)"
    end

  end
end
