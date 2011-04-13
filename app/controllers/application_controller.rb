class ApplicationController < ActionController::Base
  include BreadcrumbsOnRails::ControllerMixin
  protect_from_forgery
  before_filter :timezone_from_user
  before_filter :authenticate_user!
  before_filter :set_user_id

  private

  def admin_only
    redirect_to "errors/401" unless current_user.admin?
  end

  def timezone_from_user
    tz = current_user.try(:timezone)
    Time.zone = tz if tz.present?
  end
  
  def set_user_id
    @user_id = params[:user_id] if params[:user_id]
  end

  def user_from_path
    @user ||= User.find_by_screen_name(params[:user_id]) if params[:user_id]
  end
  
  def ensure_owned
    if !current_user || current_user.to_param != @user_id
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
    current_user && current_user.screen_name_matches?(@user_id)
  end

  def admin?
    current_user.admin?
  end
end
