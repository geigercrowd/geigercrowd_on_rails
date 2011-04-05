class WelcomeController < ApplicationController
  
  def index
    render :text => "Welcome to Geigercrowd.net", :layout => true
  end
end
