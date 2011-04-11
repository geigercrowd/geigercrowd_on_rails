require_relative '../test_helper'

class InstrumentsControllerGlobalApiTest < ActionController::TestCase
  tests InstrumentsController

  context "using the global api" do
    setup do
      @instrument = Factory.build :instrument
      @user = @instrument.user
      @user.confirm!
      @instruments = []
      10.times do |i|
        @instruments <<  Factory(:instrument, updated_at: i.days.ago)
      end
      @old_constant = Instrument::ROWS_PER_PAGE
      Instrument.__send__(:remove_const,'ROWS_PER_PAGE') 
      Instrument.const_set('ROWS_PER_PAGE', 2) 
      assert_equal 2, Instrument::ROWS_PER_PAGE
    end
    
    teardown do
      Instrument.__send__(:remove_const,'ROWS_PER_PAGE')
      Instrument.const_set('ROWS_PER_PAGE', @old_constant)
    end
    
    should "return the #{Instrument::ROWS_PER_PAGE} last updated instruments" do
      get :list, format: 'json', api_key: @user.authentication_token
      assert_response :success

      data = JSON.parse(response.body)
      #pp @sequence.collect(&:updated_at).zip data.collect {|x| x["updated_at"]}
      assert_equal 2, data.length
      assert_equal @instruments[0].id, data[0]['id']
      assert_equal @instruments[1].id, data[1]['id']
    end
    
    should "return the next #{Instrument::ROWS_PER_PAGE} last updated instrument page=2" do
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
