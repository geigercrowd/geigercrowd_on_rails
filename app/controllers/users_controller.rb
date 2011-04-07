class UsersController < ApplicationController

  respond_to :html

  before_filter :admin_only

  # GET /users
  def index
    @users = User.all
    respond_with @users
  end

  # GET /users/1
  def show
    @user = User.find_by_screen_name(params[:id])
    respond_with @user
  end

  # GET /users/new
  def new
    @user = User.new
    respond_with @user
  end

  # GET /users/1/edit
  def edit
    @user = User.find_by_screen_name(params[:id])
    respond_with @user
  end

  # POST /users
  def create
    @user = User.new(params[:user])
    if @user.save
      respond_with @user
    else
      respond_with { render :new }
    end
  end

  # PUT /users/1
  def update
    @user = User.find_by_screen_name(params[:id])

    if @user.update_attributes(params[:user])
      respond_with @user
    else
      respond_with { render :edit }
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find_by_screen_name(params[:id])
    @user.destroy
    respond_with @user
  end
end
