require_relative '../test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  context "instruments" do
    setup do
      @our_instrument = Factory :instrument
      @user = @our_instrument.user
      sign_in @user

      @other_instrument = Factory :instrument
    end

    context "of the current user" do
      should "be listed" do
        get :index, user_id: @user.to_param
        assert_response :success
        assert_equal [ @our_instrument ], assigns(:instruments)
      end

      should "be new" do
        get :new, user_id: @user.to_param
        assert_response :success
      end

      should "be created with location" do
        instrument = Factory.build :instrument, location: nil
        assert_nil instrument.location
        location = Factory.build :location, user: @user
        assert_difference('Instrument.count') do
          post :create, user_id: @user.to_param, instrument:
            { model: instrument.model, data_type_id: instrument.data_type_id,
              location_attributes:
              { latitude: location.latitude, longitude: location.longitude }}
        end
        assert_redirected_to user_instrument_path(@user, assigns(:instrument))
        assert_equal location.latitude, Instrument.last.location.latitude
        assert_equal location.longitude, Instrument.last.location.longitude
        assert_equal @user, Instrument.last.user
      end

      should "be created without location" do
        instrument = Factory.build :instrument, location: nil
        assert_nil instrument.location
        assert_difference('Instrument.count') do
          post :create, user_id: @user.to_param, instrument: { model: "fubarator",
            location_attributes: { latitude: "", longitude: "" }}
        end
        assert_redirected_to user_instrument_path(@user, assigns(:instrument))
        assert_nil Instrument.last.location
        assert_equal @user, Instrument.last.user
      end

      should "ignore wrong user_id on creation" do
        instrument = Factory.build :instrument, location: nil
        assert_nil instrument.location
        assert instrument.user.to_param
        assert_not_equal @user, instrument.user
        assert_difference('Instrument.count') do
          post :create, {instrument: instrument.attributes, user_id: @user.to_param}
        end
        assert_redirected_to user_instrument_path(@user, assigns(:instrument))
        assert_equal @user, Instrument.last.user
      end

      should "be shown" do
        get :show, :id => @our_instrument.to_param, user_id: @user.to_param
        assert_response :success
        assert_equal @our_instrument, assigns(:instrument)
      end

      should "be editable" do
        get :edit, :id => @our_instrument.to_param, user_id: @user.to_param
        assert_response :success
        assert_equal @our_instrument, assigns(:instrument)
      end
      
      should "destroy instrument" do
        assert_difference('Instrument.count', -1) do
          delete :destroy, :id => @our_instrument.to_param, user_id: @user.to_param
        end
        assert_redirected_to user_instruments_path
      end
    end

    context "of others" do
      should "not be updated" do
        old_model = @other_instrument.model
        assert_not_equal @other_instrument.user_id, @user.to_param
        put :update, id: @other_instrument.id, model: "Gray Face 2000", user_id: @user.to_param
        assert_response :success
        assert_template :show
        @other_instrument.reload
        assert_equal old_model, @other_instrument.model
      end
      
      should "be shown" do
        get :show, :id => @other_instrument.to_param, user_id: @other_instrument.user.to_param
        assert_response :success
        assert_equal @other_instrument, assigns(:instrument)
      end
    end
  end

  context "instruments of others" do
    setup do
      @our_instrument = Factory :instrument
      @user = @our_instrument.user
      @other_instrument = Factory :instrument
    end

    should "be listed" do
      get :index, user_id: @user.to_param
      assert_response :success
      assert_equal [ @our_instrument ], assigns(:instruments)
    end

    should "be shown" do
      get :show, :id => @our_instrument.to_param, user_id: @user.to_param
      assert_response :success
      assert_equal @our_instrument, assigns(:instrument)
    end

    should "not be new" do
      get :new, user_id: @user.to_param
      assert_redirected_to new_user_session_path
    end

    should "not be created with location" do
      instrument = Factory.build :instrument, location: nil
      assert_nil instrument.location
      location = Factory.build :location, user: @user
      assert_no_difference('Instrument.count') do
        post :create, user_id: @user.to_param, instrument: instrument.attributes.
          merge(location_attributes: location.attributes)
      end
      assert_redirected_to new_user_session_path
    end

    should "not be editable" do
      sign_in @user
      get :edit, :id => @other_instrument.to_param, user_id: @user.to_param
      assert_response :unauthorized
      assert_equal @other_instrument, assigns(:instrument)
    end
    
    should "not destroy instrument" do
      assert_no_difference('Instrument.count') do
        delete :destroy, :id => @other_instrument.to_param, user_id: @user.to_param
      end
      assert_redirected_to new_user_session_path
    end
  end

  
  context "using the api" do
    setup do
      @our_instrument = Factory :instrument
      @user = @our_instrument.user

      @other_instrument = Factory :instrument
    end
    
    should "be listed using the api_key" do
      get :index, :api_key => @user.authentication_token, user_id: @user.to_param
      assert_response :success
      assert_equal [ @our_instrument ], assigns(:instruments)
    end
    
    should "return a json formatted list" do
      get :index, :api_key => @user.authentication_token, :format => 'json', user_id: @user.to_param
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 1, data.length
      assert_equal delete_dates(@our_instrument.attributes), delete_dates(data[0])
    end
    
    should "be created with location" do
      instrument = Factory.build :instrument, location: nil
      assert_nil instrument.location
      location = Factory.build :location, user: @user
      assert_difference('Instrument.count') do
        post :create, { user_id: @user.to_param, :api_key => @user.authentication_token, :format => 'json', 
                        location: {latitude: location.latitude, longitude: location.longitude, name: location.name } }
                        .merge(instrument.attributes.except('user_id'))
      end
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal "Kaleidoscope", data['model']
      assert_equal location.name, data['location']['name']
    end

    should "be created without location" do
      instrument = Factory.build :instrument, location: nil
      assert_nil instrument.location
      assert_difference('Instrument.count') do
        post :create, { user_id: @user.to_param, :api_key => @user.authentication_token, :format => 'json', model: "fubarator",
          location_latitude: "", location_longitude: "" } 
      end
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal "fubarator", data['model']
      assert_nil Instrument.last.location
      assert_equal @user, Instrument.last.user
    end
    
    should "be updated" do
      put :update, { user_id: @user.to_param, id: @our_instrument.to_param,
        api_key: @user.authentication_token, format: 'json', model: "edited" }
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal 'edited', data['model']
    end

    should "be shown" do
      get :show, :id => @our_instrument.to_param, user_id: @user.to_param, :api_key => @user.authentication_token, :format => 'json'
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal @our_instrument.to_json, response.body
    end

    should "destroy instrument" do
      assert_difference('Instrument.count', -1) do
        delete :destroy, :id => @our_instrument.to_param, user_id: @user.to_param, :api_key => @user.authentication_token, :format => 'json'
      end
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal @our_instrument.to_json, response.body
    end
    
    should "not destroy other users instrument" do
      assert_no_difference('Instrument.count') do
        delete :destroy, :id => @other_instrument.to_param, user_id: @user.to_param, :api_key => @user.authentication_token, :format => 'json'
      end
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal "you do not own this instrument.", data['error']
    end
      
    should "not be editable by others" do
      get :edit, id: @other_instrument.to_param,
        user_id: @other_instrument.user.to_param,
        api_key: @user.authentication_token, format: 'json'
      assert_equal '406', response.code
      data = JSON.parse(response.body)
      assert_equal Hash, data.class 
      assert_equal "you do not own this entry.", data['error']
    end
  end

end
