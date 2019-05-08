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

    end
  end
end