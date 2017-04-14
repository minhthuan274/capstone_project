require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
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

  test "search" do 
    get books_path, params: { search: 'book' }
    assert_template 'books/index'
    assert_select "a[href=?]", book_path(@book)
    assert_select "a[href=?]", book_path(@book2)        
  end
end
