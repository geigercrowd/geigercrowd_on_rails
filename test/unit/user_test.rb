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

    should "not have an invalid screen_name" do
      user = User.create screen_name: "fübert-2000"
      assert !user.valid?
      assert_equal ["must only contain letters, numbers and dashes"], user.errors[:screen_name]
    end

    should "have a valid screen name" do
      user = User.create screen_name: "foobert-2000", password: "foobar",
        password_confirmation: "foobar", email: "foo@bar.xxx"
      assert user.valid?
    end

    should "not change his screen name" do
      @user.screen_name = "awesome_new_screen_name"
      assert !@user.save
      assert_equal({ screen_name: [ "can't be changed" ]}, @user.errors)
    end

    should "have a case insensitive screen_name" do
      assert_equal @user.id, User.find_by_screen_name(@user.screen_name).id
      assert_equal @user.id, User.find_by_screen_name(@user.screen_name.downcase).id
      assert_equal @user.id, User.find_by_screen_name(@user.screen_name.upcase).id
    end
  end
end
