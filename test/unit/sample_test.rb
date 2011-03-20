require_relative '../test_helper'

class SampleTest < ActiveSupport::TestCase
  context "sample" do
    setup do
      @sample =  Factory(:sample)
    end

    should "belong to a user through an instrument" do
      assert_equal @sample.instrument.user, @sample.user
      assert_equal @sample, @sample.instrument.user.samples.first
    end
  end
end
