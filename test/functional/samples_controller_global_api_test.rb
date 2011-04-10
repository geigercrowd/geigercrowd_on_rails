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
      should "return samples not older than 1 week" do
        get :list, format: 'json', api_key: @user.authentication_token
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 7, data.length
      end
     
      should "return one sample per instrument" do
        sample = @samples.first
        assert sample.timestamp > 1.week.ago
        Factory :sample, instrument: sample.instrument, timestamp: DateTime.now
        get :list, format: 'json', api_key: @user.authentication_token
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal data.uniq.size, data.size
        assert_equal 7, data.length
      end
    end
    
    context "pagination" do
      setup do
        50.times do |i|
          @samples << Factory(:sample, timestamp: DateTime.now)
        end
        assert_equal 60, Sample.count
      end

      should "return samples for page=2" do
        get :list, format: 'json', api_key: @user.authentication_token, page: 2
        assert_response :success
        data = JSON.parse(response.body)
        assert_equal 3, data.length
      end
    end
    
    should "return an empty list for page=5" do
      get :list, format: 'json', api_key: @user.authentication_token, page: 5
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 0, data.length
    end
    
    should "return the last_changed instrument" do
      get :list, format: 'json', api_key: @user.authentication_token, option: 'last_changed'
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2, data.length
      assert_equal @samples[9].id, data[0]['id']
      assert_equal @samples[8].id, data[1]['id']
    end
    
    should "return the second last_changed instrument with page=1" do
      get :list, format: 'json', api_key: @user.authentication_token, option: 'last_changed', page: 1
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2, data.length
      assert_equal @samples[7].id, data[0]['id']
      assert_equal @samples[6].id, data[1]['id']
    end
 
  end
end
