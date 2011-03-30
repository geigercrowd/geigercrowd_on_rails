require_relative '../test_helper'

class SamplesControllerTest < ActionController::TestCase
  context "samples" do
    setup do
      @us = Factory :user
      @us.confirm!
      sign_in @us

      @our_sample = Factory :sample, user: @us
      @other_user = Factory :user
      @other_sample = Factory :sample, user: @other_user
    end

    should "show all samples associated with a given instrument" do
      get :index
      assert_response :success
      assert_equal [ @our_sample ], assigns(:samples)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "create sample" do
      assert_difference('Sample.count') do
        post :create, :sample => { value: 1.234 }
      end
      assert_redirected_to new_instrument_sample_path
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
