module Spina::Shop
  class Country < Zone
    has_many :customers, dependent: :restrict_with_exception
    
    def flag
      case code.to_s.downcase
      when "nl"
        "🇳🇱"
      when "de"
        "🇩🇪"
      when "fr"
        "🇫🇷"
      when "be"
        "🇧🇪"
      when "es"
        "🇪🇸"
      when "at"
        "🇦🇹"
      when "ch"
        "🇨🇭"
      when "gb"
        "🇬🇧"
      when "it"
        "🇮🇹"
      when "lu"
        "🇱🇺"
      when "se"
        "🇸🇪"
      when "fi"
        "🇫🇮"
      when "hu"
        "🇭🇺"
      when "pt"
        "🇵🇹"
      when "pl"
        "🇵🇱"
      else
        code
      end
    end
  end
end