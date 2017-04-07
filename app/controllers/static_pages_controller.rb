class StaticPagesController < ApplicationController

  before_action :admin_user, only: [:return]

  def home
    if @user = current_user
      unless @user.admin?
        @borrowings = @user.borrowings.where("verified LIKE ?", true)
        @books = Array.new
        @borrowings.each { |b| @books << Book.find_by(id: b.book_id) }
      else
        @borrowings = Borrowing.where.not(request: nil)
      end
    end
  end

  def about
  end

  def return
    if params[:search_user_id] 
      if @user = User.find_by(id: params[:search_user_id])
        @borrowings = @user.borrowings
      else
        flash[:warning] = "Not found user"
      end
    end
    store_location
  end

  private
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end
