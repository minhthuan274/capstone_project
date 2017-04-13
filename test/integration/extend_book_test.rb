require 'test_helper'

class ExtendBookTest < ActionDispatch::IntegrationTest
  def setup
    @lib   = users(:lib)
    @user  = users(:user)
    @user_max_borrow  = users(:user_max_borrow)
    @user_extend = users(:user_should_extend)
    @book  = books(:book)
    @book_not_available  = books(:book_not_available)
    @borrowing = borrowings(:borrowing)
    @borrowing_max_extend = borrowings(:borrowing_max_extend)
  end  

  test "extend book" do 
    #log_in_as @user
  end
end
