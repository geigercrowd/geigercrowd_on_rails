require_relative '../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "Users" do
    setup do
      @admin = Factory :admin
      @user = Factory :user
      @other_user = Factory :user
    end

    context "from an admin's point of view" do
      setup do
        sign_in @admin
      end

      should "be listed" do
        get :index
        assert_response :success
        assert_equal User.all, assigns(:users)
      end

      should "be shown" do
        get :show, id: @user.to_param
        assert_response :success
      end

      should "be editable" do
        get :edit, id: @user.to_param
        assert_response :success
      end

      should "be updated" do
        assert_not_equal "Foobert", @user.real_name
        put :update, id: @user.to_param, user: { real_name: "Foobert" }
        assert_redirected_to @user
        @user.reload
        assert_equal "Foobert", @user.real_name
      end

      should "be deletable" do
        assert_difference('User.count', -1) do
          delete :destroy, id: @user.to_param
        end
        assert_redirected_to users_path
      end
    end

    context "- other users" do
      setup do
        sign_in @other_user
      end

      should "not see them all at once" do
        get :index
        assert_redirected_to "errors/401"
      end

      should "see their profiles" do
        get :show, id: @user.to_param
        assert_response :success
        assert_equal @user, assigns(:user)
      end

      should "not edit them" do
        get :edit, id: @user.to_param
        assert_redirected_to "errors/401"
      end

      should "not delete them" do
        assert_no_difference "User.count" do
          delete :destroy, id: @user.to_param
        end
        assert_redirected_to "errors/401"
      end

      should "not update them" do
        put :update, id: @user.to_param, user: { real_name: "Foobert" }
        assert_redirected_to "errors/401"
        @user.reload
        assert_not_equal "Foobert", @user.real_name
      end
    end

    context "themselves" do
      setup do
        sign_in @user
      end

      should "update their data" do
        put :update, id: @user.to_param.upcase, user: { real_name: "Foobert" }
        @user.reload
        assert_redirected_to @user
        assert_equal "Foobert", @user.real_name
      end
    end
  end
end
