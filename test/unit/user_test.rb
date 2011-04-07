# encoding: utf-8
require_relative '../test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User" do
    setup do 
      @user = Factory :user
    end

    should "create a authentication_token" do
      assert_not_nil @user.authentication_token
    end

    should "save a timezone's name" do
      tz = ActiveSupport::TimeZone.new "Berlin"
      @user.timezone = tz
      assert_equal "Berlin", @user.read_attribute(:timezone)
      assert_equal tz, @user.timezone
    end

    should "save nil when timezone is given as name but doesn't exist" do
      @user.timezone = "Fubaria"
      assert_nil @user.timezone
    end

    should "validate screen_name" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :user, screen_name: "FÄIL"
      end
    end

    should "have a case insensitive screen_name" do
      assert_equal @user.id, User.find_by_screen_name(@user.screen_name).id
      assert_equal @user.id, User.find_by_screen_name(@user.screen_name.downcase).id
      assert_equal @user.id, User.find_by_screen_name(@user.screen_name.upcase).id
    end
  end
end
