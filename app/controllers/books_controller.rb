class BooksController < ApplicationController

  before_action :current_user_admin?,    only: [:new, :create, :edit, :update, :destroy]


  def index
    @books = Book.search(params[:search])
  end

  def show
    @book = Book.find(params[:id])
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
      if @book.save 
        flash[:success] = "This book has been added."
        redirect_to @book
      else
        render 'new'
      end
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
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
    def current_user_admin?
      unless current_user.admin?
        flash[:danger] = "You's not got enouch permision to do it."
        redirect_to root_url
      end
    end

    def book_params
      params.require(:book).permit(:title, :year, :publisher, :author)
    end
end
