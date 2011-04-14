require_relative '../test_helper'

  
class SourcesControllerTest < ActionController::TestCase
  context "sources" do
    setup do
      #@instrument = Factory :instrument
      @ds = Factory :data_source
      #@instrument.origin = @ds
      #@ds.instruments = [@instrument]
    end

    should "be listed" do
      get :index
      assert_response :success
      assert_equal [ @ds ], assigns(:sources)
    end

  end
end
