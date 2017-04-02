class BorrowingsController < ApplicationController

  before_action :logged_in?,            only: [:create, :update, :destroy]
  before_action :get_user_and_book,     only: [:create, :update, :destroy]
  before_action :admin_user,            only: [:update]
  before_action :get_borrowing,         only: [:update, :destroy]
  

  def index

  end

  def create
    if @book.available?
      @borrowing = Borrowing.create(user_id:  params[:user_id],
                                    book_id:  params[:book_id],
                                    due_time: Time.zone.now + 2.weeks)
      @book.borrowed
      flash[:success] = "Requested."
      redirect_to @book
    else
      flash[:warning] = ""
      redirect_to 
    end

  end

  

  def update
    if params[:verify] 
      @borrowing.verify_borrow_book
      params[:verify] = nil
    elsif params[:extend] 
      @borrowing.extend_due_time(params[:due_time])
      params[:extend] = nil
    else
      flash[:danger] = "You did something wrong!"    
    end
    redirect_to root_url
  end

  def destroy 
    if current_user_admin? #only deny request borrow book and request extend
      
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
end
