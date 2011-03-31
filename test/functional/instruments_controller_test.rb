require_relative '../test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  context "instruments" do
    setup do
      @instrument = Factory :instrument
      @user = @instrument.user
      @user.confirm!
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

    should "be created with location" do
      instrument = Factory.build :instrument, user: @user, location: nil
      assert_nil instrument.location
      location = Factory.build :location, user: @user
      assert_difference('Instrument.count') do
        post :create, instrument: instrument.attributes.
          merge(location_attributes: location.attributes)
      end
      assert_equal location.latitude, Instrument.last.location.latitude
      assert_equal location.longitude, Instrument.last.location.longitude
      assert_redirected_to instrument_path(assigns(:instrument))
    end

    should "be created without location" do
      instrument = Factory.build :instrument, location: nil
      assert_nil instrument.location
      location = Factory.build :location, longitude: nil, latitude: nil, user: @user
      assert_difference('Instrument.count') do
        post :create, instrument: { model: "fubarator",
          location_attributes: { latitude: "", longitude: "" }}
      end
      assert_nil Instrument.last.location
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

    should "destroy instrument" do
      assert_difference('Instrument.count', -1) do
        delete :destroy, :id => @instrument.to_param
      end
      assert_redirected_to instruments_path
    end
  end
end
