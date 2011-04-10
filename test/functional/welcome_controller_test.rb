require_relative '../test_helper'

class WelcomeControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  should "render the index" do
    get :index
  end
  
  should "render the api index" do
    get :api
  end
  
  should "render the public api docs" do
    get :api_public
  end
  
  should "render the private api docs" do
    get :api_private
  end
end
