class UsersController < ApplicationController

  respond_to :html
  before_filter :admin_only, except: [ :show, :update ]
  skip_before_filter :authenticate_user!
  
  # GET /users
  def index
    @users = User.all
    respond_with @users
  end

  # GET /users/1
  def show
    @user = User.find_by_screen_name params[:id]
    respond_with @user
  end

  # GET /users/new
  def new
    @user = User.new
    respond_with @user
  end

  # GET /users/1/edit
  def edit
    @user = User.find_by_screen_name params[:id]
    respond_with @user
  end

  # PUT /users/1
  def update
    if in_person? || admin?
      @user = in_person? ? current_user : User.find_by_screen_name(params[:id])
      @user.update_attributes params[:user]
      respond_with @user
    else
      redirect_to "errors/401"
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find_by_screen_name params[:id]
    @user.destroy
    respond_with @user
  end

  private

  def in_person?
    current_user && current_user.screen_name_matches?(params[:id])
  end
end
