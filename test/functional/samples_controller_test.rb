require_relative '../test_helper'

class SamplesControllerTest < ActionController::TestCase
  context "samples" do
    setup do
      @our_sample = Factory :sample
      @us = @our_sample.user
      sign_in @us

      @other_sample = Factory :sample
      assert_equal 2, Sample.count
    end

    should "show all samples associated with a given instrument" do
      get :index, instrument_id: @our_sample.instrument.id, user_id: @us.to_param
      assert_response :success
      assert_equal [ @our_sample ], assigns(:samples)
    end

    should "fail when the user-instrument combination doesn't exist" do
      get :index, user_id: @other_sample.user.to_param,
        instrument_id: @our_sample.instrument.id
      assert_response :forbidden
    end

    should "be new" do
      get :new, instrument_id: @our_sample.instrument.id, user_id: @us.to_param
      assert_response :success
    end

    should "be created" do
      assert_difference('@our_sample.instrument.samples.count') do
        post :create, user_id: @us.to_param,
          instrument_id: @our_sample.instrument.id,
          sample: { value: 1.234, timestamp: DateTime.now },
      end
      assert_redirected_to new_user_instrument_sample_path
    end

    should "be created with the correct timezone" do
      Time.zone = "UTC"
      timestamp = '2011-04-06 09:09'
      assert_difference('@our_sample.instrument.samples.count') do
        post :create, instrument_id: @our_sample.instrument.id,
          sample: { value: 1.234, timestamp: timestamp,
            timezone: "Berlin" }, user_id: @us.to_param
      end
      assert_equal "Berlin", Time.zone.name
      offset = Time.zone.utc_offset
      sample = Sample.last
      # FIXME is that weird or is it just me?
      offset += 3600 if sample.timestamp.dst?

      assert_equal timestamp, (sample.timestamp.utc + offset.seconds).
        strftime('%Y-%m-%d %H:%M')
    end

    should "be updated with the correct timezone" do
      Time.zone = "UTC"
      timestamp = '2011-04-06 09:09'
      post :update, user_id: @us.to_param, instrument_id: @our_sample.instrument.id,
        id: @our_sample.id, sample: { value: 1.234, timestamp: timestamp,
          timezone: "Berlin" }
      assert_equal "Berlin", Time.zone.name
      offset = Time.zone.utc_offset
      @our_sample.reload
      # FIXME is that weird or is it just me?
      offset += 3600 if @our_sample.timestamp.dst?

      assert_equal timestamp, (@our_sample.timestamp.utc + offset.seconds).
        strftime('%Y-%m-%d %H:%M')
    end

    should "be shown" do
      get :show, instrument_id: @our_sample.instrument.id,
                            id: @our_sample.to_param,
                            user_id: @us.to_param
      assert_response :success
    end

    should "be editable" do
      get :edit,   id: @our_sample.to_param,
        instrument_id: @our_sample.instrument.id, 
              user_id: @us.to_param
      assert_response :success
    end

    should "be updated" do
      time = DateTime.now
      put :update, id: @our_sample.to_param,
        instrument_id: @our_sample.instrument.id,
        sample: { value: 123.45, timestamp: time },
        user_id: @us.to_param
      assert_redirected_to user_instrument_sample_path(@us, assigns(:sample).instrument,
                                                  assigns(:sample))
      @our_sample.reload
      assert_equal time, assigns(:sample).timestamp
      assert_equal 123.45, assigns(:sample).value
    end

    should "be destroyable" do
      assert_difference('Sample.count', -1) do
        delete :destroy, id: @our_sample.to_param,
          instrument_id: @our_sample.instrument.id,
          user_id: @us.to_param
      end
      assert_redirected_to user_instrument_samples_path @us, @our_sample.instrument
    end

    context "timezone in form" do
      should "be set to UTC if we don't know better" do
        Time.zone = "UTC"
        @us.update_attribute :timezone, nil
        get :new, instrument_id: @our_sample.instrument.id, user_id: @us.to_param
        assert_equal "UTC", Hpricot(@response.body).
          search('select#sample_timezone option[@selected]').first[:value]
      end

      should "be set to the user's timezone, if he has one set" do
        Time.zone = "UTC"
        @us.update_attribute :timezone, ActiveSupport::TimeZone.new("Berlin")
        get :new, instrument_id: @our_sample.instrument.id, user_id: @us.to_param
        assert_equal "Berlin", Hpricot(@response.body).
          search('select#sample_timezone option[@selected]').first[:value]
      end

      should "be set if otherwise determined" do
        Time.zone = "Berlin"
        @us.update_attribute :timezone, nil
        get :new, instrument_id: @our_sample.instrument.id, user_id: @us.to_param
        assert_equal "Berlin", Hpricot(@response.body).
          search('select#sample_timezone option[@selected]').first[:value]
      end
    end

    context "of other users" do
      should "not be updated" do
        old_times = @other_sample.timestamp
        old_values = @other_sample.value
        put :update, id: @our_sample.id,
          instrument_id: @our_sample.instrument.id,
          user_id: @other_sample.user.to_param,
          sample: { value:     old_values + 5.0,
                    timestamp: old_times - 1.day }
        assert_template "errors/403"
        @other_sample.reload
        assert_equal old_times.to_s, @other_sample.timestamp.to_s
        assert_equal old_values, @other_sample.value
      end

      should "not be created" do
        assert_no_difference("Sample.count") do
          post :create, instrument_id: @other_sample.instrument.id,
            sample: { value: 1.4, timestamp: DateTime.now },
            user_id: @us.to_param
        end
        assert_response :forbidden
        assert_template "errors/403"
      end
    end
  end

  context "samples of other users" do
    setup do
      @other_sample = Factory :sample
      @us = @other_sample.user
      sign_in @us

      @other_sample = Factory :sample
      assert_equal 2, Sample.count
    end

    should "be indexable" do
      get :index, instrument_id: @other_sample.instrument.id,
        user_id: @other_sample.user.to_param
      assert_response :success
      assert_equal [ @other_sample ], assigns(:samples)
    end

    should "be shown" do
      get :show, instrument_id: @other_sample.instrument.id,
        id: @other_sample.id, user_id: @other_sample.user.to_param
      assert_response :success
    end

    should "not be new" do
      get :new, instrument_id: @other_sample.instrument.id, user_id: @other_sample.user.to_param
      assert_response :forbidden
    end

    should "not be creatable" do
      assert_no_difference('@other_sample.instrument.samples.count') do
        post :create, instrument_id: @other_sample.instrument,
          sample: { value: 1.234, timestamp: DateTime.now },
          user_id: @other_sample.user.to_param
      end
      assert_response :forbidden
    end

    should "not be editable" do
      get :edit, :id => @other_sample.to_param,
        instrument_id: @other_sample.instrument.id, 
        user_id: @other_sample.user.to_param
      assert_response :forbidden
    end

    should "not be updated" do
      time = DateTime.now
      put :update, id: @other_sample.to_param,
        instrument_id: @other_sample.instrument.id,
        sample: { value: 123.45, timestamp: time },
        user_id: @other_sample.user.to_param
      assert_response :forbidden
    end

    should "not be destroyable" do
      assert_no_difference('Sample.count') do
        delete :destroy, id: @other_sample.to_param,
          instrument_id: @other_sample.instrument.id,
          user_id: @other_sample.user.to_param
      end
      assert_response :forbidden
    end
  end



  context "using the api" do
    setup do
      @our_sample = Factory :sample
      @us = @our_sample.user

      @other_sample = Factory :sample
      assert_equal 2, Sample.count
    end

    should "show all samples associated with a given instrument" do
      get :index, instrument_id: @our_sample.instrument.id, user_id: @us.to_param, 
                  api_key: @us.authentication_token, format: 'json'
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 1, data.length
      assert_equal delete_dates(@our_sample.attributes), delete_dates(data[0])
    end

    should "be creatable" do
      assert_difference('@our_sample.instrument.samples.count') do
        post :create, instrument_id: @our_sample.instrument, user_id: @us.to_param,
          value: 1.234, timestamp: DateTime.now,
          api_key: @us.authentication_token, format: 'json'
      end
      data = JSON.parse(response.body)
      assert_equal Hash, data.class
      assert_equal data['value'], 1.234
    end

    should "be creatable with a location" do
      assert_difference('@our_sample.instrument.samples.count') do
        @our_sample.instrument.update_attribute :location, nil
        post :create, instrument_id: @our_sample.instrument.id,
          user_id: @us.to_param, value: 1.234, timestamp: DateTime.now,
          location: { name: 'optional', latitude: 1.0, longitude: 0.1 },
          api_key: @us.authentication_token, format: 'json'
      end
      data = JSON.parse(response.body)
      assert_equal Hash, data.class
      assert_equal data['value'], 1.234
      assert_not_nil data['location']
      assert_equal 'optional', data['location']['name']
    end
    
    should "not be creatable without any location" do
      assert @our_sample.instrument.
        update_attributes location: nil, new_location: true
      assert_no_difference('@our_sample.instrument.samples.count') do
        post :create, instrument_id: @our_sample.instrument.id,
          user_id: @us.to_param, value: 1.234, timestamp: DateTime.now,
          api_key: @us.authentication_token, format: 'json'
      end
      data = JSON.parse(response.body)
      assert_equal({ "location" => ["can't be blank"] }, JSON.parse(response.body))
      assert_response :unprocessable_entity
    end

    should "be shown" do
      get :show, instrument_id: @our_sample.instrument.id,
                            id: @our_sample.to_param, user_id: @us.to_param,
                            api_key: @us.authentication_token, format: 'json'
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal Hash, data.class
      assert_equal @our_sample.id, data["id"]
    end

    should "be updated" do
      time = DateTime.now
      put :update, id: @our_sample.to_param,
        instrument_id: @our_sample.instrument.id,
        value: 123.45, timestamp: time, user_id: @us.to_param,
        api_key: @us.authentication_token, format: 'json'
      @our_sample.reload
      data = JSON.parse(response.body)
      assert_equal Hash, data.class
      assert_equal 123.45, data["value"]
    end

    should "be destroyable" do
      assert_difference('Sample.count', -1) do
        delete :destroy, id: @our_sample.to_param,
          instrument_id: @our_sample.instrument.id, user_id: @us.to_param,
          api_key: @us.authentication_token, format: 'json'
      end
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal Hash.new, data
    end

    should "return something if non existent sample should be destroyed" do
      delete :destroy, id: Sample.maximum(:id) + 1,
        instrument_id: @our_sample.instrument.id, user_id: @us.to_param,
        api_key: @us.authentication_token, format: 'json'
      assert_response :not_found
      assert_equal({"errors"=>{"sample"=>"not found"}}, JSON.parse(response.body))
    end

    context "of other users" do
      should "not be updated" do
        old_times = @other_sample.timestamp
        old_values = @other_sample.value
        put :update, id: @other_sample.to_param,
          instrument_id: @other_sample.instrument.id,
          sample: { value:     old_values + 5.0,
                    timestamp: old_times - 1.day },
          user_id: @us.to_param,
          api_key: @us.authentication_token, format: 'json'
        assert_response :forbidden
        @other_sample.reload
        assert_equal old_values, @other_sample.value
        assert_equal old_times.to_s, @other_sample.timestamp.to_s
      end

      should "not be created" do
        assert_no_difference("Sample.count") do
          post :create, instrument_id: @other_sample.instrument.id,
            sample: { value: 1.4, timestamp: DateTime.now },
            user_id: @us.to_param,
            api_key: @us.authentication_token, format: 'json'
        end
        assert_response :forbidden
      end
      
      should "not be created with an invalid api_key" do
        post :create, instrument_id: @our_sample.instrument.id,
          sample: { value: 1.4, timestamp: DateTime.now },
          user_id: @us.to_param,
          api_key: 'invalid', format: 'json'
        assert_equal '401', response.code
      end
      
      should "not be editable" do
        get :edit, instrument_id: @other_sample.instrument.id, id: @other_sample.id,
          user_id: @us.to_param, api_key: @us.authentication_token, format: 'json'
        assert_response :forbidden
      end
      
      should "not destroy other users instrument" do
        assert_no_difference('Sample.count') do
          delete :destroy, id: @other_sample.id,
            instrument_id: @other_sample.instrument.id, user_id: @us.to_param,
            api_key: @us.authentication_token, format: 'json'
        end
        assert_response :forbidden
        data = JSON.parse(response.body)
        assert_equal Hash, data.class
      end
    end
  end

  context "location" do
    setup do
      @sample_sf = Factory :sample, location_attributes:
        { latitude: 37.7749295, longitude: -122.4194155 }
      @sample_paris = Factory :sample, location_attributes:
        { latitude: 48.856614, longitude: 2.352222 }
      @sample_ny = Factory :sample, location_attributes:
        { latitude: 40.7143528, longitude: -74.0059731 }
      @origin = "Berlin, Germany"
    end
   
    should "be sorted by distance" do
      post :find, location: @origin
      assert_equal [ @sample_paris, @sample_ny, @sample_sf ], assigns(:samples)
    end
  end
end
