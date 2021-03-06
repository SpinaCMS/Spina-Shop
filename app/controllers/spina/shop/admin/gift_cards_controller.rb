module Spina::Shop
  module Admin
    class GiftCardsController < AdminController
      before_action :set_gift_card, only: [:show, :edit, :update, :destroy]
      before_action :set_breadcrumbs

      def index
        @q = GiftCard.order(created_at: :desc).ransack(params[:q])
        @gift_cards = @q.result.page(params[:page]).per(25)
      end

      def unused
        @q = GiftCard.order(created_at: :desc).where('value = remaining_balance').ransack(params[:q])
        @gift_cards = @q.result.page(params[:page]).per(25)
        render :index
      end

      def show
        add_breadcrumb @gift_card.readable_code
      end

      def new
        @gift_card = GiftCard.new(expires_at: 1.year.from_now)
        add_breadcrumb t('spina.shop.gift_cards.new')
      end

      def create
        @gift_card = GiftCard.new(gift_card_params)
        
        if @gift_card.save
          redirect_to spina.shop_admin_gift_cards_path
        else
          flash.now[:alert] = "Error"
          flash.now[:alert_small] = @gift_card.errors.full_messages.join("<br />")
          add_breadcrumb t('spina.shop.gift_cards.new')
          render :new
        end
      end
      
      def edit
        add_breadcrumb @gift_card.readable_code
      end
      
      def update
        if @gift_card.update(gift_card_expiration_params)
          redirect_to spina.shop_admin_gift_card_path(@gift_card)
        else
          add_breadcrumb @gift_card.readable_code
          render :edit
        end
      end

      def destroy
        @gift_card.destroy
        redirect_to spina.shop_admin_gift_cards_path
      rescue ActiveRecord::DeleteRestrictionError
        flash[:alert] = t('spina.shop.gift_cards.delete_restriction_error')
        flash[:alert_small] = t('spina.shop.gift_cards.delete_restriction_error_explanation')
        redirect_to spina.shop_admin_gift_card_path(@gift_card)
      end

      private

        def set_gift_card
          @gift_card = GiftCard.find(params[:id])
        end

        def set_breadcrumbs
          add_breadcrumb GiftCard.model_name.human(count: 2), spina.shop_admin_gift_cards_path
        end
        
        def gift_card_expiration_params
          params.require(:gift_card).permit(:expires_at)
        end

        def gift_card_params
          params.require(:gift_card).permit(:code, :expires_at, :value)
        end

    end
  end
end
