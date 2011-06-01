require_relative '../test_helper'

class SamplesControllerGlobalApiTest < ActionController::TestCase
  tests SamplesController

  context "using the global api" do
    setup do
      @instrument = Factory.build :instrument
      @user = @instrument.user
      @samples = []
      10.times do |i|
        @samples <<  Factory(:sample, timestamp: (i.days + 1.hour).ago)
      end
    end

    context "defaults" do
      should "return samples not older than 1 day" do
        get :find, format: 'json', api_key: @user.authentication_token
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 1, data.length
      end
      
      should "respect the after parameter" do
        get :find, format: 'json', api_key: @user.authentication_token, after: 100.days.ago
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 10, data.length
      end
      
      should "respect the before parameter" do
        get :find, format: 'json', api_key: @user.authentication_token,
          before: 5.days.ago.to_date.to_s, after: 1.week.ago.to_date.to_s
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 2, data.length
      end
      
      should "respect both the before and after parameter" do
        get :find, format: 'json', api_key: @user.authentication_token, before: 5.days.ago, after: 100.days.ago
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 5, data.length
      end
    end
       
    # TODO: adapt to will_paginate
    context "pagination" do
      setup do
        Sample.per_page.times do |i|
          @samples << Factory(:sample, timestamp: DateTime.now)
        end
        assert_equal Sample.per_page + 10, Sample.count
      end

      should "return samples for page=2" do
        get :find, format: 'json', api_key: @user.authentication_token, page: 2, after: 1.week.ago.to_date.to_s
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 8, data.length
      end
    end
    
    should "return an empty list for page=5" do
      get :find, format: 'json', api_key: @user.authentication_token, page: 5
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 0, data.length
    end
    
    should "return only the latest samples" do
      sample = @samples.first
      assert sample.timestamp > 1.week.ago
      Factory :sample, instrument: sample.instrument, timestamp: DateTime.now
      get :find, format: 'json', api_key: @user.authentication_token
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 1,
        data.select { |s| s["instrument_id"] == sample.instrument_id }.size
    end

    should "return not only the latest samples" do
      sample = @samples.first
      assert sample.timestamp > 1.week.ago
      Factory :sample, instrument: sample.instrument, timestamp: DateTime.now
      get :find, format: 'json', api_key: @user.authentication_token, options: [ "history" ]
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2,
        data.select { |s| s["instrument_id"] == sample.instrument_id }.size
    end
  end
end
