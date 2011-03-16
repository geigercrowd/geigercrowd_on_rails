require 'test_helper'

class SamplesControllerTest < ActionController::TestCase
  setup do
    @sample = samples(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:samples)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sample" do
    assert_difference('Sample.count') do
      post :create, :sample => @sample.attributes
    end

    assert_redirected_to sample_path(assigns(:sample))
  end

  test "should show sample" do
    get :show, :id => @sample.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sample.to_param
    assert_response :success
  end

  test "should update sample" do
    put :update, :id => @sample.to_param, :sample => @sample.attributes
    assert_redirected_to sample_path(assigns(:sample))
  end

  test "should destroy sample" do
    assert_difference('Sample.count', -1) do
      delete :destroy, :id => @sample.to_param
    end

    assert_redirected_to samples_path
  end
end
