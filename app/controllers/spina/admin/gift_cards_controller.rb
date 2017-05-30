module Spina
  module Admin
    class GiftCardsController < AdminController
      before_action :set_gift_card, only: [:show, :destroy]
      before_action :set_breadcrumbs

      def index
        @gift_cards = Spina::GiftCard.order(created_at: :desc)
      end

      def show
      end

      def new
        @gift_card = Spina::GiftCard.new(expires_at: 1.year.from_now)
        add_breadcrumb t('spina.shop.gift_cards.new')
      end

      def create
        @gift_card = Spina::GiftCard.new(gift_card_params)
        
        if @gift_card.save
          redirect_to admin_gift_cards_path
        else
          flash.now[:alert] = "Error"
          flash.now[:alert_small] = @gift_card.errors.full_messages.join("<br />")
          add_breadcrumb t('spina.shop.gift_cards.new')
          render :new
        end
      end

      def destroy
      end

      private

        def set_gift_card
          @gift_card = Spina::GiftCard.find(params[:id])
        end

        def set_breadcrumbs
          add_breadcrumb Spina::GiftCard.model_name.human(count: 2), admin_gift_cards_path
        end

        def gift_card_params
          params.require(:gift_card).permit(:code, :expires_at, :value)
        end

    end
  end
end
