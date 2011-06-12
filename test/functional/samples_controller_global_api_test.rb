require_relative '../test_helper'

class SamplesControllerGlobalApiTest < ActionController::TestCase
  tests SamplesController

  context "using the global api" do
    setup do
      @instrument = Factory.build :instrument
      @user = @instrument.user
      @samples = []
      10.times do |i|
        @samples <<  Factory(:sample, timestamp: i.days.ago)
      end
    end

    context "defaults" do
      should "respect the after parameter" do
        get :find, format: 'json', api_key: @user.authentication_token,
          after: formatted_date(100.days.ago), location: "Berlin, Germany"
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 10, data.length
      end
      
      should "respect the before parameter" do
        get :find, format: 'json', api_key: @user.authentication_token,
          after: formatted_date(1.year.ago),
          before: formatted_date(5.days.ago), location: "Berlin, Germany"
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 4, data.length
      end
      
      should "respect both the before and after parameter" do
        get :find, format: 'json', api_key: @user.authentication_token,
          before: formatted_date(5.days.ago), after: formatted_date(100.days.ago), location: "Berlin, Germany"
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 4, data.length
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
        get :find, format: 'json', api_key: @user.authentication_token,
          page: 2, location: "Berlin, Germany",
          after: formatted_date(1.week.ago)
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 8, data.length
      end
    end
    
    should "return an empty list for page=5" do
      get :find, format: 'json', api_key: @user.authentication_token,
        page: 5, location: "Berlin, Germany"
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 0, data.length
    end
    
    should "return only the latest samples" do
      sample = @samples.first
      assert sample.timestamp > 1.day.ago.midnight
      Factory :sample, instrument: sample.instrument, timestamp: DateTime.now
      get :find, format: 'json', api_key: @user.authentication_token,
        location: "Berlin, Germany"
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 1,
        data.select { |s| s["instrument_id"] == sample.instrument_id }.size,
        data.inspect
    end

    should "return not only the latest samples" do
      sample = @samples.first
      assert sample.timestamp > 1.week.ago
      Factory :sample, instrument: sample.instrument, timestamp: DateTime.now
      get :find, format: 'json', api_key: @user.authentication_token,
        options: [ "history" ], location: "Berlin, Germany"
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2,
        data.select { |s| s["instrument_id"] == sample.instrument_id }.size
    end
  end

  private

  def formatted_date date
    date.to_date.strftime '%F'
  end
end
