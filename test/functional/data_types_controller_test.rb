require 'test_helper'

class DataTypesControllerTest < ActionController::TestCase
  setup do
    @data_type = data_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_type" do
    assert_difference('DataType.count') do
      post :create, :data_type => @data_type.attributes
    end

    assert_redirected_to data_type_path(assigns(:data_type))
  end

  test "should show data_type" do
    get :show, :id => @data_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @data_type.to_param
    assert_response :success
  end

  test "should update data_type" do
    put :update, :id => @data_type.to_param, :data_type => @data_type.attributes
    assert_redirected_to data_type_path(assigns(:data_type))
  end

  test "should destroy data_type" do
    assert_difference('DataType.count', -1) do
      delete :destroy, :id => @data_type.to_param
    end

    assert_redirected_to data_types_path
  end
end
