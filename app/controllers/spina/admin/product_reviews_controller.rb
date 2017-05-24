module Spina
  module Admin
    class ProductReviewsController < AdminController
      
      def index
        @product_reviews = Spina::ProductReview.sorted.page(params[:page]).per(25)
        add_breadcrumb Spina::ProductReview.model_name.human(count: :other)
      end

      def delete_multiple
        Spina::ProductReview.where(id: params[:product_review_ids]).destroy_all
        redirect_to spina.admin_product_reviews_path
      end

    end
  end
end