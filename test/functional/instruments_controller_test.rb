require_relative '../test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  context "instrument" do
    setup do
      @user = Factory :user
      @user.confirm!
      @instrument = Factory :instrument
      @user.instruments << @instrument
      sign_in @user
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:instruments)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "be created" do
      assert_difference('Instrument.count') do
        post :create, :instrument => Factory.build(:instrument).attributes
      end
      assert_redirected_to instrument_path(assigns(:instrument))
    end

    should "show instrument" do
      get :show, :id => @instrument.to_param
      assert_response :success
    end

    should "get edit" do
      get :edit, :id => @instrument.to_param
      assert_response :success
    end

    should "update instrument" do
      put :update, :id => @instrument.to_param, :instrument => @instrument.attributes
      assert_redirected_to instrument_path(assigns(:instrument))
    end

    should "destroy instrument" do
      assert_difference('Instrument.count', -1) do
        delete :destroy, :id => @instrument.to_param
      end
      assert_redirected_to instruments_path
    end
  end
end
