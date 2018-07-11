class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :destroy, :index, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :is_admin_user,       only: [:index]
  before_action :is_admin_or_correct_user, only: [:destroy]
  
 include UsersHelper
  
  def new
    @user = User.new
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    if (@user = User.new(user_params)).save
      log_in @user
      flash[:success] = 'signed up'
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    # todo: delete all feeds and records etc. involving this user
    me = current_user
    if me.id == @user.id
      # bye bye me
      redirect_to root_url
      @user.destroy
      log_out
    else
      # must be an adminner
      @user.destroy
      redirect_to users_url
    end
    flash[:success] = "User #{@user.email} deleted"
  end

  private

  def logged_in_user
    return if logged_in?
    flash[:danger] = 'Please log in'
    store_location
    redirect_to login_url
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url if !current_user?(@user)
  end

  def is_admin_user
    redirect_to root_url if !current_user.admin?
  end

  def is_admin_or_correct_user
    @user = User.find(params[:id])
    redirect_to root_url if !(current_user.admin? || current_user?(@user))
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
