require 'test_helper'

class RequestBorrowBookTest < ActionDispatch::IntegrationTest
  def setup
    @lib   = users(:lib)
    @user  = users(:user)
    @borrow_max_user  = users(:borrow_max_user)
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
end
