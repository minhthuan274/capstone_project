class StaticPagesController < ApplicationController
  def home
    if @user = current_user
      unless @user.admin?
        @borrowings = @user.borrowings.where("verified LIKE ?", true)
        @books = Array.new
        @borrowings.each { |b| @books << Book.find_by(id: b.book_id) }
      else

      end
    end
  end

  def about
  end
end
