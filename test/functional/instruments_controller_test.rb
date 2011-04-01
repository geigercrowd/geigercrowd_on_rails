require_relative '../test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  context "instruments" do
    setup do
      @our_instrument = Factory :instrument
      @user = @our_instrument.user
      @user.confirm!
      sign_in @user

      @other_instrument = Factory :instrument
    end

    context "of the current user" do
      should "be listed" do
        get :index
        assert_response :success
        assert_equal [ @our_instrument ], assigns(:instruments)
      end

      should "be new" do
        get :new
        assert_response :success
      end

      should "be created with location" do
        instrument = Factory.build :instrument, location: nil
        assert_nil instrument.location
        location = Factory.build :location, user: @user
        assert_difference('Instrument.count') do
          post :create, instrument: instrument.attributes.
            merge(location_attributes: location.attributes)
        end
        assert_redirected_to instrument_path(assigns(:instrument))
        assert_equal location.latitude, Instrument.last.location.latitude
        assert_equal location.longitude, Instrument.last.location.longitude
        assert_equal @user, Instrument.last.user
      end

      should "be created without location" do
        instrument = Factory.build :instrument, location: nil
        assert_nil instrument.location
        assert_difference('Instrument.count') do
          post :create, instrument: { model: "fubarator",
            location_attributes: { latitude: "", longitude: "" }}
        end
        assert_redirected_to instrument_path(assigns(:instrument))
        assert_nil Instrument.last.location
        assert_equal @user, Instrument.last.user
      end

      should "ignore wrong user_id on creation" do
        instrument = Factory.build :instrument, location: nil
        assert_nil instrument.location
        assert instrument.user.id
        assert_not_equal @user, instrument.user
        assert_difference('Instrument.count') do
          post :create, instrument: instrument.attributes
        end
        assert_redirected_to instrument_path(assigns(:instrument))
        assert_equal @user, Instrument.last.user
      end

      should "be shown" do
        get :show, :id => @our_instrument.to_param
        assert_response :success
        assert_equal @our_instrument, assigns(:instrument)
      end

      should "be editable" do
        get :edit, :id => @our_instrument.to_param
        assert_response :success
        assert_equal @our_instrument, assigns(:instrument)
      end

      should "destroy instrument" do
        assert_difference('Instrument.count', -1) do
          delete :destroy, :id => @our_instrument.to_param
        end
        assert_redirected_to instruments_path
      end
    end

    context "of others" do
      should "not be updated" do
        old_model = @other_instrument.model
        put :update, id: @other_instrument.id, model: "Gray Face 2000"
        assert_response :success
        assert_template :show
        @other_instrument.reload
        assert_equal old_model, @other_instrument.model
      end
    end
  end
end
