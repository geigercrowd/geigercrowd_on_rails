require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User" do
    setup do 
      @user = Factory :user
    end
    should "create a authentication_token" do
      assert_not_nil @user.authentication_token
    end
  end
end
