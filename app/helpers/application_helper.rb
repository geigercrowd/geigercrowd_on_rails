module ApplicationHelper
  def timezone
    current_user.timezone || Time.zone
  end
  def is_owned?
    current_user and current_user.id == @user_id
  end
end
