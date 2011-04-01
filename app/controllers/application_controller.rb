class ApplicationController < ActionController::Base
  include BreadcrumbsOnRails::ControllerMixin
  protect_from_forgery
  before_filter :authenticate_user!

  private

  def admin_only
    redirect_to "errors/401" unless current_user.admin?
  end
end
