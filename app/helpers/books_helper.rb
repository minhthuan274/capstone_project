module BooksHelper
  def current_book
    Book.find_by(id: session[:book_id])
  end
end
