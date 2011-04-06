require_relative '../test_helper'

class InstrumentsControllerGlobalApiTest < ActionController::TestCase
  tests InstrumentsController

  context "using the global api" do
    setup do
      @instrument = Factory.build :instrument
      @user = @instrument.user
      @user.confirm!
      @sequence = []
      10.times do |i|
        @sequence <<  Factory(:instrument_sequence)
      end
      Instrument.stubs(:list_limit).returns(2)
      assert_equal 2, Instrument.list_limit
    end

    should "return Instrument.limit_amount of instruments" do
      get :list, format: 'json', api_key: @user.authentication_token
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 2, data.length
      assert_equal @sequence[0].id, data[0]['id']
      assert_equal @sequence[1].id, data[1]['id']
    end
    
    should "return the 5th and 6th instrument for page=2" do
      get :list, format: 'json', api_key: @user.authentication_token, page: 2
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 2, data.length
      #pp @sequence.collect(&:id).zip data.collect {|x| x["id"]}

      assert_equal @sequence[4].id, data[0]['id']
      assert_equal @sequence[5].id, data[1]['id']
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
      #pp @sequence.collect(&:updated_at).zip data.collect {|x| x["updated_at"]}
      assert_equal 2, data.length
      assert_equal @sequence[9].id, data[0]['id']
      assert_equal @sequence[8].id, data[1]['id']
    end
    
    should "return the second last_changed instrument with page=1" do
      get :list, format: 'json', api_key: @user.authentication_token, option: 'last_changed', page: 1
      assert_response :success

      data = JSON.parse(response.body)
      assert_equal 2, data.length
      assert_equal @sequence[7].id, data[0]['id']
      assert_equal @sequence[6].id, data[1]['id']
    end
 
  end
end
