class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  # case 1: expired reset (done in a handler)
  # case 2: invalid password
  # case 3: empty password confirmation
  # case 4: successful
  def update
    if params[:user][:password].empty? # case 3:
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params) # 4
      log_in @user
      flash[:success] = "Password has been reset"
      @user.clear_reset_info
      redirect_to @user
    else
      render 'edit' #2: invalid
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired"
      redirect_to new_password_reset_url
    end
  end
  
  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    if !(@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end
end
