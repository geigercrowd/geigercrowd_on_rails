require_relative '../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "users" do
    setup do
      @user = Factory :user
      @admin = Factory :admin
      sign_in @admin
    end

    should "be listed" do
      get :index
      assert_response :success
      assert_equal User.all, assigns(:users)
    end

    should "have a profile" do
      get :show, :id => @user.to_param
      assert_response :success
    end

    should "be editable by admins" do
      get :edit, :id => @user.to_param
      assert_response :success
    end

    should "not be editable by users"
    should "be able to update himself"
    should "be updateable by admins"
    should "not be updateable by others"

    should "be deletable" do
      assert_difference('User.count', -1) do
        delete :destroy, :id => @user.to_param
      end

      assert_redirected_to users_path
    end
  end
end
