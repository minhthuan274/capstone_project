require 'test_helper'

class ExtendBookTest < ActionDispatch::IntegrationTest
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

  test "extend book and lib approve" do 
    log_in_as @user_extend 
    get root_path 

    assert_template 'static_pages/home'
    assert_select 'tr.danger', count: 2
    assert_select 'form.edit_borrowing'
    assert_select 'input.extend-btn', count: 2

    #Send extend
    borrowing = @borrowing_extend
    patch borrowing_path borrowing, params: { request_extend: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id,
                                              extension_day: 8}
    borrowing.reload
    old_borrowing_due_date = borrowing.due_date
    times_extended_old = borrowing.times_extended
    assert_equal 8, borrowing.time_extend
    assert_not_nil borrowing.request
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'tr.danger', count: 2
    assert_select 'form.edit_borrowing'
    assert_select 'input.extend-btn', count: 1
    assert_not flash.empty?

    log_in_as @lib
    get root_path
    assert_select 'input.approve-btn'
    assert_select 'input.deny-btn'
    patch borrowing_path borrowing, params: { extend_book: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id }
    borrowing.reload
    @user_extend.reload
    assert_not_equal old_borrowing_due_date, borrowing.due_date
    assert_equal     1, borrowing.times_extended - times_extended_old
  end

  test "deny request extend" do
    log_in_as @user_extend 
    get root_path 

    borrowing = @borrowing_extend
    patch borrowing_path borrowing, params: { request_extend: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id,
                                              extension_day: 8}
    borrowing.reload
    old_borrowing_due_date = borrowing.due_date
    times_extended_old = borrowing.times_extended

    log_in_as @lib
    get root_path
    assert_select 'input.approve-btn'
    assert_select 'input.deny-btn'
    delete borrowing_path borrowing, params: { extend_book: true,
                                               user_id: borrowing.user_id,
                                               book_id: borrowing.book_id }
    borrowing.reload
    @user_extend.reload
    assert_equal old_borrowing_due_date, borrowing.due_date
    assert_equal     0, borrowing.times_extended - times_extended_old

  end


  test "can't extend more than 3 times" do 
    log_in_as @user_extend
    borrowing = @borrowing_max_extend
    patch borrowing_path borrowing, params: { request_extend: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id,
                                              extension_day: 8}
    follow_redirect!
    assert_not flash.empty?
    assert  "You extended 3 times. Not allow to extend again." ,
             flash[:warning] 
  end

  test "cannot extend more 2 weeks" do
    log_in_as @user_extend
    borrowing = @borrowing_extend
    patch borrowing_path borrowing, params: { request_extend: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id,
                                              extension_day: 15}
    follow_redirect!
    assert_not flash.empty?
    assert "You can't extend more than 2 weeks.",
           flash[:warning]
  end

  test "extension day can't be blank or less than 1" do 
    log_in_as @user_extend
    borrowing = @borrowing_extend
    patch borrowing_path borrowing, params: { request_extend: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id,
                                              }
    follow_redirect!
    assert_not flash.empty?
    assert "Extension days should be greater than 0",
           flash[:warning]

    patch borrowing_path borrowing, params: { request_extend: true,
                                              user_id: borrowing.user_id,
                                              book_id: borrowing.book_id,
                                              extension_day: -2}
    follow_redirect!
    assert_not flash.empty?
    assert "Extension days should be greater than 0",
           flash[:warning]
  end
end
