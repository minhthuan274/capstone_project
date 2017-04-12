require 'test_helper'

class RequestBorrowBookTest < ActionDispatch::IntegrationTest
  def setup
    @lib   = users(:lib)
    @user  = users(:user)
    @borrow_max_user  = users(:user_max_borrow)
    @book  = books(:book)
    @book_not_available  = books(:book_not_available)
    @borrowing = borrowings(:borrowing)
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
    # assert_select 'form.new_borrowing'
    # assert_select "input.borrow-btn"
    assert_difference "Borrowing.count", 1 do
      post borrowings_path, params: { user_id: @user.id, 
                                      book_id: @book.id, }
    end
    assert_not flash.empty?
    assert_redirected_to @book
    follow_redirect!
    assert_template 'books/show'
    # assert_select 'form.edit_borrowing'
    # assert_select 'form input.cancel-btn'

    log_in_as(@lib, remember_me: '1')
    get root_path 
    assert_select 'input.approve-btn'
    assert_select 'input.deny-btn'
  end

  test "approve request borrow" do
    log_in_as @user
    post borrowings_path, params: { user_id: @user.id, 
                                    book_id: @book.id, }
    log_in_as @lib
    get root_path 
    borrowing = Borrowing.find_by(user_id: @user.id, 
                                  book_id: @book.id)
    b = @user.number_borrowed_books
    patch borrowing_path borrowing, params: { verify_book: true,
                                              user_id: @user.id,
                                              book_id: @book.id}
    assert @user.number_borrowed_books - b
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'input.approve-btn', count: 0
    assert_select 'input.deny-btn', false
    log_in_as(@user, remember_me: '1')
    assert is_logged_in?
    get root_path 
    assert_select "a[href=?]", book_path(@book), count: 0
  end


end
