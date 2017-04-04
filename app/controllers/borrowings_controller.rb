class BorrowingsController < ApplicationController

  before_action :must_be_logged_in,     only: [:create, :update, :destroy]
  before_action :get_user_and_book,     only: [:create, :update, :destroy]
  before_action :get_borrowing,         only: [:update, :destroy]
  

  def index
  end

  def create
    if @book.available?
      if current_user?(@user) and current_user.available_to_borrow? 
        @borrowing = Borrowing.create(user_id:  params[:user_id],
                                      book_id:  params[:book_id],
                                      due_time: Time.zone.now + 2.weeks)
        @book.borrowed
        flash[:success] = "Request borrow book has been sent"
      else
        flash[:warning] = "You can't borrow any book"
      end
      redirect_to @book
    else
      flash[:warning] = ""
      redirect_to root_url
    end

  end
  
  def update
    if current_user.admin?
      # verify borrow book
      if params[:verify_book] 
        if @user.available_to_borrow? 
          @borrowing.verify_borrow_book
        else
          flash[:danger] = "Can't approve request borrow this book"
        end
      # Send request extend time borrow books
      elsif params[:extend_book] 
        @borrowing.extend_due_time(@borrowing.time_extend)
      end
    # Non admin
    elsif current_user(@user) && params[:request_extend]
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
      elsif params[:extend_book] # Deny extend book 
        @borrowing.deny_extend_book
      else
        flash[:warning] = "You did something wrong"
      end
  
    else
      if current_user?(User.find_by(id: params[:user_id]))
        @borrowing.destroy
        flash[:success] = "Your request has been cancel"
        redirect_to Book.find_by(id: params[:book_id])
      else
        flash[:danger] = "You did something you are not allowed."
        redirect_to root_url
      end
    end
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

    # Confirm the admin user.
    def admin_user
      redirect_to root_url unless current_user.admin?
    end

    def check_extend_book(extension_days)
      days = extension_days.to_i

      if @borrowing.times_extended == 3
        flash[:warning] = "You extended 3 times. Not allow to extend once more." 
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
      redirect_to login_path unless logged_in?
    end
end
