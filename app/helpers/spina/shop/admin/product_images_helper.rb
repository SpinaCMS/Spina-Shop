module Spina::Shop
  module Admin
    module ProductImagesHelper

      def variant(image, options)
        if image.file.attached?
          variant = image.file.variant(options)
          main_app.rails_blob_representation_path(variant.blob.signed_id, variant.variation.key, variant.blob.filename)
        else
          "https://placehold.it/100x100.png"
        end
      end
      
    end
  end
end