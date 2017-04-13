class BorrowingsController < ApplicationController
  
  before_action :must_be_logged_in,     only: [:create, :update, :destroy, :return]
  before_action :get_user_and_book,     only: [:create, :update, :destroy]
  before_action :get_borrowing,         only: [:update, :destroy]
  before_action :admin_user,            only: [:return]

  def index
  end

  def create
    if @book.available?
      if current_user?(@user) and current_user.available_to_borrow? 
        @borrowing = Borrowing.create(user_id:  params[:user_id],
                                      book_id:  params[:book_id],
                                      due_date: Time.zone.now + 2.weeks)
        @book.borrowed
        flash[:success] = "Request borrow book has been sent"
      else
        flash[:warning] = "You can't borrow any book"
      end
      redirect_to @book
    else
      flash[:warning] = "This book is not available"
      redirect_to root_url
    end

  end
  
  def update
    if current_user_admin?
      # verify borrow book
      if params[:verify_book] 
        if @user.available_to_borrow? 
          @borrowing.verify_borrow_book
          @user.borrow_book
        else
          flash[:danger] = "Can't approve request borrow this book"
        end
      # Send request extend time borrow books
      elsif params[:extend_book] 
        @borrowing.extend_due_date(@borrowing.time_extend)
      end
    # Non admin
    elsif current_user?(@user) && params[:request_extend]
      check_extend_book(params[:extension_day])
    else
      flash[:danger] = "You did something wrong!"
    end
    redirect_to root_url
  end

  def destroy 
    if current_user_admin? 
      if params[:verify_book]  # Deny request borrow book
        @borrowing.destroy
        @book.return_book
      elsif params[:extend_book] # Deny extend book 
        @borrowing.deny_extend_book
      else
        flash[:warning] = "You did something wrong"
      end
  
    else
      if current_user?(User.find_by(id: params[:user_id]))
        @borrowing.destroy
        @book.return_book
        flash[:success] = "Your request has been canceled"
        redirect_to Book.find_by(id: params[:book_id])
      else
        flash[:danger] = "You did something you are not allowed."
      end
    end
    redirect_to root_url
  end

  def return
    borrowing = Borrowing.find_by(id: params[:borrowing_id])
    borrowing.destroy 
    book = Book.find_by(id: borrowing.book_id)
    user = User.find_by(id: borrowing.user_id)
    user.return_book
    book.return_book

    redirect_back_or(root_path)
  end


  private
    def get_user_and_book
      @user = User.find(params[:user_id])
      @book = Book.find(params[:book_id])
    end

    def get_borrowing
      @borrowing = Borrowing.find_by(user_id: params[:user_id], 
                                     book_id: params[:book_id])
    end

    def check_extend_book(extension_days)
      days = extension_days.to_i

      if @borrowing.times_extended == 3
        flash[:warning] = "You extended 3 times. Not allow to extend again." 
      elsif days <= 0 
        flash[:warning] = "Extension days should be greater than 0"
      elsif days > 14 
        flash[:warning] = "You can't extend more than 2 weeks."
      else
        flash[:success] = "Request has been sent"
        @borrowing.update_request_extend(days)
      end
    end 

    def must_be_logged_in
      unless logged_in?
        store_location
        redirect_to login_path 
      end
    end
    def admin_user
      unless current_user_admin? 
        flash[:danger] = "You're not admin user!"
        redirect_to root_url
      end
    end
end