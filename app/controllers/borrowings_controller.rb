class BorrowingsController < ApplicationController

  before_action :get_user_and_book,     only: [:create, :update, :destroy]
  before_action :current_user_admin?,   only: [:update]
  before_action :get_borrowing,         only: [:update]
  

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
    if current_user.admin? #only deny request borrow book and request extend
      
    else
      
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
end
