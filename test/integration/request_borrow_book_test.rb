require 'test_helper'

class RequestBorrowBookTest < ActionDispatch::IntegrationTest
  def setup
    @lib                  = users(:lib)
    @user                 = users(:user)
    @other                = users(:other)
    @user_max_borrow      = users(:user_max_borrow)
    @user_extend          = users(:user_should_extend)

    @book                 = books(:book)
    @book2                = books(:book2)
    @book_not_available   = books(:book_not_available)
    
    @borrowing            = borrowings(:borrowing)
    @borrowing_max_extend = borrowings(:borrowing_max_extend)
  end  

  test "request borrowing" do 
    assert_no_difference "Borrowing.count" do
      post borrowings_path, params: { user_id: @user.id, 
                                      book_id: @book.id, }
    end
    assert_redirected_to login_path
    log_in_as @user
    get book_path @book
    assert_template 'books/show'
    assert_select 'form.new_borrowing'
    assert_select "input.borrow-btn"
    assert_difference "Borrowing.count", 1 do
      post borrowings_path, params: { user_id: @user.id, 
                                      book_id: @book.id, }
    end
    assert_not flash.empty?
    assert_redirected_to @book
    follow_redirect!
    assert_template 'books/show'
    assert_select 'form.edit_borrowing'
    assert_select 'form input.cancel-btn'

    log_in_as @lib
    get root_path 
    assert_select 'input.approve-btn'
    assert_select 'input.deny-btn'
  end

  test "approve request borrow" do
    log_in_as @user
    post borrowings_path, params: { user_id: @user.id, 
                                    book_id: @book.id, }
    borrowing = Borrowing.find_by(user_id: @user.id, 
                                  book_id: @book.id)
    log_in_as @lib
    get root_path 
    
    b = @user.number_borrowed_books
    patch borrowing_path borrowing, params: { verify_book: true,
                                              user_id: @user.id,
                                              book_id: @book.id}
    assert @user.number_borrowed_books - b
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'input.approve-btn', count: 0
    assert_select 'input.deny-btn', false
    log_in_as @user
    assert is_logged_in?
    get root_path 
    assert_template 'static_pages/home'
    assert_select "a[href=?]", book_path(@book), count: 1
  end

  test "deny request borrow" do
    log_in_as @user
    number_books_before = @book.availability
    number_borrowed_books = @user.number_borrowed_books
    post borrowings_path, params: { user_id: @user.id, 
                                    book_id: @book.id, }
    borrowing = Borrowing.find_by(user_id: @user.id, 
                                  book_id: @book.id)
    log_in_as @lib
    get root_path 
    assert_difference 'Borrowing.count', -1 do
      delete borrowing_path borrowing, params: { verify_book: true,
                                                 user_id: @user.id,
                                                 book_id: @book.id}
    end
    assert_select 'input.approve-btn', false
    assert_select 'input.deny-btn', false

    assert_equal(number_books_before, @book.availability)
    assert_equal(number_borrowed_books, @user.number_borrowed_books)
    log_in_as @user
    get root_path 
    assert_template 'static_pages/home'
    assert_select "a[href=?]", book_path(@book), count: 0
  end

  test "user should extend book can't borrow book" do 
    log_in_as @user_extend 
    get book_path @book2 
    assert_no_difference "Borrowing.count" do
      post borrowings_path, params: { user_id: @user_extend.id, 
                                      book_id: @book2.id, }
    end
    assert_not flash.empty?
  end


  test "user max borrow book cannot borrow book" do 
    log_in_as @user_max_borrow 
    get book_path @book2 
    assert_no_difference "Borrowing.count" do
      post borrowings_path, params: { user_id: @user_max_borrow.id, 
                                      book_id: @book2.id, }
    end
    assert_not flash.empty?
  end

  test "user cannot borrow book for other user" do
    log_in_as @user
    get book_path @book 
    assert_no_difference "Borrowing.count" do
      post borrowings_path, params: { user_id: @other.id, 
                                      book_id: @book.id, }
    end
    assert_not flash.empty?
  end

  test "Book not available can't be borrowed" do 
    log_in_as @user
    get book_path @book_not_available
    assert_no_difference "Borrowing.count" do
      post borrowings_path, params: { user_id: @other.id, 
                                      book_id: @book_not_available.id, }
    end
    assert_not flash.empty?
  end
end
