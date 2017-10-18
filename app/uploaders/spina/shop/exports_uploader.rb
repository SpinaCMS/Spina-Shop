module Spina::Shop
  class ExportsUploader < CarrierWave::Uploader::Base

    def store_dir
      "exports"
    end

  end
end