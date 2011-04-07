module ApplicationHelper
  def title(title)
    @title = title
  end
  def timezone
    current_user.timezone || Time.zone
  end
  def is_owned?
    current_user and current_user.id == @user_id
  end
  def api_key
    current_user ? current_user.authentication_token : '<YOUR API KEY>'
  end
  def user_id
    current_user ? current_user.id : '<YOUR USER ID>'
  end
end
