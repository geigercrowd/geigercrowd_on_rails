require "application_responder"

class ApplicationController < ActionController::Base
  include BreadcrumbsOnRails::ControllerMixin
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery
  before_filter :timezone_from_user
  before_filter :authenticate_user!
  before_filter :set_origin

  private

  def admin_only
    redirect_to "errors/401" unless current_user.admin?
  end

  def timezone_from_user
    tz = current_user.try(:timezone)
    Time.zone = tz if tz.present?
  end
  
  def set_origin
    if params[:user_id]
      @origin = User.find_by_screen_name(params[:user_id])
    elsif params[:data_source_id]
      @origin = DataSource.find_by_short_name(params[:data_source_id])
    end
  end

  def user_from_path
    if params[:user_id]
     if current_user.screen_name_matches? params[:user_id] 
       current_user
     else
       @user_from_path ||= User.find_by_screen_name(params[:user_id]) if params[:user_id]
     end
    end
  end
  
  def ensure_owned
    if !current_user || current_user != @origin
      respond_to do |format|
        format.html {
          begin
            redirect_to :back
          rescue ActionController::RedirectBackError
            redirect_to root_path
          end
        }
        format.json {
          render :json => {"error" => "you do not own this entry."}, :status => 406
        }
      end
    end
  end
  
  def is_owned?
    current_user == @origin
  end

  def admin?
    current_user && current_user.admin?
  end
end
