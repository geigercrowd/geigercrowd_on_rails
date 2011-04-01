require_relative '../test_helper'

class DataTypesControllerTest < ActionController::TestCase
  context "data types" do
    setup do
      @admin = Factory :admin
      @user = Factory :user
      @data_type = Factory :data_type
    end

    should "not be accessible for regular users" do
      sign_in @user
      { index: :get,
        new: :get,
        show: :get,
        edit: :get,
        update: :put,
        create: :post,
        destroy: :delete
      }.each do |action, verb|
        send(verb, action, id: @data_type.id)
        assert_redirected_to "errors/401"
      end
    end

    context "admins" do
      setup do
        sign_in @admin
      end

      should "get listed" do
        get :index
        assert_response :success
        assert_equal [ @data_type ], assigns(:data_types)
      end

      should "be able to put in" do
        get :new
        assert_response :success
      end

      should "be able to create" do
        assert_difference('DataType.count') do
          post :create, :data_type => @data_type.attributes
        end

        assert_redirected_to data_type_path(assigns(:data_type))
      end

      should "see" do
        get :show, :id => @data_type.to_param
        assert_response :success
      end

      should "be able to edit" do
        get :edit, :id => @data_type.to_param
        assert_response :success
      end

      should "be able to update" do
        put :update, :id => @data_type.to_param, :data_type => @data_type.attributes
        assert_redirected_to data_type_path(assigns(:data_type))
      end

      should "be able to destroy" do
        assert_difference('DataType.count', -1) do
          delete :destroy, :id => @data_type.to_param
        end

        assert_redirected_to data_types_path
      end
    end
  end
end
