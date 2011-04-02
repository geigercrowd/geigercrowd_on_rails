class ApplicationController < ActionController::Base
  include BreadcrumbsOnRails::ControllerMixin
  protect_from_forgery
  before_filter :timezone_from_user
  before_filter :authenticate_user!

  private

  def admin_only
    redirect_to "errors/401" unless current_user.admin?
  end

  def timezone_from_user
    tz = current_user.try(:timezone)
    Time.zone = tz if tz.present?
  end
end
