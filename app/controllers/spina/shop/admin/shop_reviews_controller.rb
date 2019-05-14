module Spina::Shop
  module Admin
    class ShopReviewsController < AdminController
      layout 'spina/shop/admin/reviews'
      
      def index
        @shop_reviews = ShopReview.sorted.page(params[:page]).per(25)
        add_breadcrumb ShopReview.model_name.human(count: :other)
      end

      def batch_update
        if params[:button] == "delete"
          ShopReview.where(id: params[:shop_review_ids]).destroy_all
        elsif params[:button] == "approve"
          ShopReview.where(id: params[:shop_review_ids]).update_all(approved: true)
        end
        redirect_to spina.shop_admin_shop_reviews_path
      end

      def edit
        @shop_review = ShopReview.find(params[:id])
        add_breadcrumb ShopReview.model_name.human(count: :other), spina.shop_admin_shop_reviews_path
        add_breadcrumb @shop_review.author
        render layout: "spina/admin/admin"
      end

      def update
        @shop_review = ShopReview.find(params[:id])
        if @shop_review.update_attributes(shop_review_params)
          redirect_to spina.shop_admin_shop_reviews_path
        else
          render :edit
        end
      end

      private

        def shop_review_params
          params.require(:shop_review).permit(:author, :review_pros, :review_cons, :score, :score_communication, :score_speed, :approved, :email)
        end

    end
  end
end