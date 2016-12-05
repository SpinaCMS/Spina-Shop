require 'net/http'

module Spina
  class Untappd
    CLIENT_ID = "3731FC096C8913722090B5B7B6CBED80CB176649"
    CLIENT_SECRET = "168F5C57162EA5DD97348DE29A2D8389B6124046"
    API_URL = "https://api.untappd.com/v4/"

    class << self

      def import_data_in_table
        category = Spina::ProductCategory.find_by(name: 'Bier')
        limit = 100
        Spina::Product.where(product_category: category).all.each do |product|
          if limit > 0
            beer = UntappdBeer.where(untappd_id: product.properties['untappd']).first
            if beer.blank?
              url = URI("#{API_URL}beer/info/#{product.properties['untappd']}")
              response = send_request(url)
              if response.present? && response['response'].present? && response['response']['beer'].present?
                untappd_id = response['response']['beer']['bid']
                description = response['response']['beer']['beer_description']
                rating = response['response']['beer']['rating_score']
                rating_count = response['response']['beer']['rating_count']
                style = response['response']['beer']['beer_style']

                related_beer_ids = []
                response['response']['beer']['similar']['items'].each do |beer|
                  related_beer_ids << beer['beer']['bid']
                end

                beer = UntappdBeer.where(untappd_id: product.properties['untappd']).first_or_create
                beer.update_attributes(
                  description: description,
                  rating: rating,
                  rating_count: rating_count,
                  style: style,
                  related_beer_ids: related_beer_ids.join(',')
                )
                limit = limit - 1
              end
            end
          end
        end
        puts "Limit reached"
      end

      private

        def send_request(url)
          post = Net::HTTP::Get.new(url.path + "?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}")
          request = Net::HTTP.new(url.host, url.port)
          request.use_ssl = true
          response = request.start{ |http| http.request(post) }
          decoded_json = ActiveSupport::JSON.decode(response.body)
        end
    end
  end
end