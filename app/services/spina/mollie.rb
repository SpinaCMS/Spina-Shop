require 'Mollie/API/Client'

module Spina
  class Mollie
    def self.client
      client = ::Mollie::API::Client.new
      client.api_key = Rails.application.secrets.mollie_api_key
      client
    end
  end
end