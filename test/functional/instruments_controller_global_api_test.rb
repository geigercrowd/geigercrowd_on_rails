require_relative '../test_helper'

class InstrumentsControllerGlobalApiTest < ActionController::TestCase
  tests InstrumentsController

  context "using the global api" do
    setup do
      @user = Factory.create :user
      @user.confirm!
      @original_per_page = Instrument.per_page
      Instrument.per_page = 2
      @instruments = []
      (Instrument.per_page * 5).times do |i|
        @instruments <<  Factory(:instrument, updated_at: i.days.ago)
      end
    end
    
    teardown do
      Instrument.per_page = @original_per_page
    end
    
    should "return the most recently updated instruments" do
      get :list, format: 'json', api_key: @user.authentication_token
      assert_response :success

      data = JSON.parse(response.body)
      #pp @sequence.collect(&:updated_at).zip data.collect {|x| x["updated_at"]}
      assert_equal 2, data.length
      assert_equal @instruments[0].id, data[0]['id']
      assert_equal @instruments[1].id, data[1]['id']
    end
    
    should "return page 2" do
      get :list, format: 'json', api_key: @user.authentication_token, page: 2
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2, data.length
      assert_equal @instruments[2].id, data[0]['id']
      assert_equal @instruments[3].id, data[1]['id']
    end
    
    should "not return instruments older then one week per default" do
      get :list, format: 'json', api_key: @user.authentication_token, page: 4
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 1, data.length
    end
    
    should "respect the after parameter" do
      get :list, format: 'json', api_key: @user.authentication_token, after: 1.day.ago
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 1, data.length
      assert_equal @instruments[0].id, data[0]['id']
    end
 
    should "respect the before parameter" do
      get :list, format: 'json', api_key: @user.authentication_token, before: 5.days.ago
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2, data.length
      assert_equal @instruments[5].id, data[0]['id']
      assert_equal @instruments[6].id, data[1]['id']
    end 
  end
end
