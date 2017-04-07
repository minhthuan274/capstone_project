require 'test_helper'

class ReturnBookTest < ActionDispatch::IntegrationTest
  def setup
    @thuan = users(:thuan)
    @binh  = users(:binh)
    @hary  = books(:hary)
    @bity  = books(:bity)
  end  

  test "should be logged in before return book" do 
    assert_no_difference "Borrowing.count" do
      post borrowings_path, params: { user_id: @thuan.id, 
                                      book_id: @hary.id, }
    end
    assert_redirected_to login_path
  end

  test ""

end
