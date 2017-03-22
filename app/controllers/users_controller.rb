class UsersController < ApplicationController

  def show
    @user = User.find_by(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:info] = "Please check your email to activate you account."
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find_by(params[:id])
  end

  def update
    @user = User.find_by(params[:id])
    if @user.update_attributes(user_params)

      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end


  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
