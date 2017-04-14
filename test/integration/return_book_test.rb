require 'test_helper'

class ReturnBookTest < ActionDispatch::IntegrationTest
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
    @borrowing_extend     = borrowings(:borrowing_extend)
    @borrowing_max_extend = borrowings(:borrowing_max_extend)
  end    



  test "not librarian can't return" do 
    log_in_as @user
    get return_path 
    assert_redirected_to root_path 
    borrowing = @borrowing
    assert_no_difference "Borrowing.count" do
      delete return_path, params: { borrowing_id: borrowing.id }
    end
    assert_redirected_to root_path 
    assert_not flash.empty?
    assert "You're not admin user!",
           flash[:danger]
  end

  test "regturn book" do
    log_in_as @lib 
    get return_path, params: { search_user_id: @user_extend.id}
    
    borrowing1 = @borrowing_extend
    assert_template 'static_pages/return'
    assert_select 'td', 'book 1'
    assert_select 'td', 'book 2'
    assert_difference 'Borrowing.count', - 1 do
      delete return_path, params: { borrowing_id: borrowing1.id}
    end
    follow_redirect!
    assert_template 'static_pages/return'
  end
end
