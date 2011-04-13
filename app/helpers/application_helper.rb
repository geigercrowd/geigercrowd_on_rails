module ApplicationHelper
  def title(title)
    @title = title
  end

  def timezone
    current_user.timezone || Time.zone
  end

  def is_owned?
    current_user && current_user.screen_name_matches?(@user_id)
  end

  def api_key
    current_user ? current_user.authentication_token : '<YOUR API KEY>'
  end

  def user_id
    current_user ? current_user.screen_name : '<YOUR USER ID>'
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
end
