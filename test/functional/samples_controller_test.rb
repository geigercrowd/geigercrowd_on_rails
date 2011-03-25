require_relative '../test_helper'

class SamplesControllerTest < ActionController::TestCase
  context "samples" do
    setup do
      @user = Factory :user
      @user.confirm!
      sign_in @user
      @sample = Factory :sample
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:samples)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "create sample" do
      assert_difference('Sample.count') do
        post :create, :sample => @sample.attributes
      end

      assert_redirected_to sample_path(assigns(:sample))
    end

    should "show sample" do
      get :show, :id => @sample.to_param
      assert_response :success
    end

    should "get edit" do
      get :edit, :id => @sample.to_param
      assert_response :success
    end

    should "update sample" do
      put :update, :id => @sample.to_param, :sample => @sample.attributes
      assert_redirected_to sample_path(assigns(:sample))
    end

    should "destroy sample" do
      assert_difference('Sample.count', -1) do
        delete :destroy, :id => @sample.to_param
      end

      assert_redirected_to samples_path
    end
  end
end
