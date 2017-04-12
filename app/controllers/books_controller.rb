class BooksController < ApplicationController

  before_action :logged_in_user, only: [:new, :create, :edit, 
                                              :update, :destroy]
  before_action :admin_user,     only: [:new, :create, :edit, 
                                              :update, :destroy]

  before_action :get_book,       only: [:show, :edit, :update, :destroy]


  def index
    @books = Book.search(params[:search]).paginate(page: params[:page],
                                                   per_page: 10)
  end

  def show
    session[:book_id] = params[:id]
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.find_by(title: params[:book][:title].downcase)
    if @book 
      @book.quatity += 1
      @book.save
    else
      @book = Book.new(book_params)
      @book.availability = @book.quantity
      if @book.save 
        flash[:success] = "This book has been added."
        redirect_to @book
      else
        render 'new'
      end
    end
  end

  def edit
  end

  def update
    if @book.update_attributes(book_params)
      flash[:success] = "This book has been updated."
      redirect_to @book
    else
      render 'edit'
    end
  end

  def destroy
    
  end

  private 
    def book_params
      params.require(:book).permit(:title, :year, :publisher, :author, :quantity)
    end

    def get_book
      @book = Book.find(params[:id])
    end

    def admin_user
      unless current_user_admin? 
        flash[:danger] = "You're not admin user!"
        redirect_to root_url
      end
  end
end
