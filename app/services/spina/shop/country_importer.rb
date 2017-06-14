module Spina
  module Shop
    module CountryImporter
      def self.import
        eu_members = ['Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden']
        countries = File.read(File.join(Spina::Shop.root, 'db', 'countries.txt')).tr("\r", "\n").split("\n").map { |c| c.split(/\t/) }
        countries.each do |code2, code3, name, continent, tld, currency|
          country = Country.where(name: name, code: code2).first_or_initialize
          country.save
        end
      end
    end
  end
end
