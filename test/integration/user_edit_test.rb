require 'test_helper'

class UserEditTest < ActionDispatch::IntegrationTest
    def setup
    @user       = users(:user)
    @other_user = users(:user_max_borrow)
  end

  test "unsuccessful edit" do 
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                             email: "foo@invalid",
                                             password:              "foo",
                                             password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select "div.alert", "The form contains 4 errors."
  end

  test "successful edit" do 
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo bar"
    email = "foo@bar.com" 
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal(name, @user.name)
    assert_equal(email, @user.email)
  end

  test "should redirect edit if not logged in" do 
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update if not logged in" do 
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.any?
    assert_redirected_to login_url
  end 

  test "should redirect edit when logged in as wrong user" do 
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do 
    log_in_as @other_user
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to root_url                                         
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
