class ApplicationController < ActionController::Base
  include BreadcrumbsOnRails::ControllerMixin
  protect_from_forgery
  before_filter :authenticate_user!

  private

  def admin_only
    current_user.admin
  end
end
