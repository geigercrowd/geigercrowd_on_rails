class UsersController < ApplicationController
  respond_to :html
  before_filter :admin_only, except: [ :edit, :update ]
  
  # GET /users
  def index
    @users = User.all
    respond_with @users
  end

  # GET /users/hulk
  def show
    @user = admin? ? user : current_user
    respond_with @user
  end

  # GET /users/hulk/edit
  def edit
    @user = admin? ? user : current_user
    respond_with @user
  end

  # PUT /users/hulk
  def update
    if in_person? || admin?
      @user = admin? ? user : current_user
      @user.update_attributes params[:user]
      respond_with @user do |format|
        format.html { render :edit }
      end
    else
      respond_with do |format|
        format.html { redirect_to "errors/401" }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user = user
    @user.destroy
    respond_with @user
  end

  private

  def user
    @user ||= User.find_by_screen_name params[:id]
  end

  def in_person?
    current_user && current_user.screen_name_matches?(params[:id])
  end
end
