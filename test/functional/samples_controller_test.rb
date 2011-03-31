require_relative '../test_helper'

class SamplesControllerTest < ActionController::TestCase
  context "samples" do
    setup do
      @our_sample = Factory :sample
      @us = @our_sample.user
      @us.confirm!
      sign_in @us

      @other_sample = Factory :sample
      assert_equal 2, Sample.count
    end

    should "show all samples associated with a given instrument" do
      get :index, instrument_id: @our_sample.instrument.id
      assert_response :success
      assert_equal [ @our_sample ], assigns(:samples)
    end

    should "be new" do
      get :new, instrument_id: @our_sample.instrument.id
      assert_response :success
    end

    should "be creatable" do
      assert_difference('@our_sample.instrument.samples.count') do
        post :create, instrument_id: @our_sample.instrument,
                      sample: { value: 1.234, timestamp: DateTime.now }
      end
      assert_redirected_to new_instrument_sample_path
    end

    should "be shown" do
      get :show, instrument_id: @our_sample.instrument.id,
                            id: @our_sample.to_param
      assert_response :success
    end

    should "be editable" do
      get :edit, :id => @our_sample.to_param,
        instrument_id: @our_sample.instrument.id
      assert_response :success
    end

    should "be updated" do
      time = DateTime.now
      put :update, id: @our_sample.to_param,
        instrument_id: @our_sample.instrument.id,
        sample: { value: 123.45, timestamp: time }
      assert_redirected_to instrument_sample_path(assigns(:sample).instrument,
                                                  assigns(:sample))
      @our_sample.reload
      assert_equal time, assigns(:sample).timestamp
      assert_equal 123.45, assigns(:sample).value
    end

    should "be destroyable" do
      assert_difference('Sample.count', -1) do
        delete :destroy, id: @our_sample.to_param,
          instrument_id: @our_sample.instrument.id
      end
      assert_redirected_to instrument_samples_path @our_sample.instrument
    end
  end
end
