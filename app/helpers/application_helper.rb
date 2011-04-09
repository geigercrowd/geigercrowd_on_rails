module ApplicationHelper

  def timezone
    current_user.timezone || Time.zone
  end

  def is_owned?
    current_user && current_user.screen_name_matches?(@user_id)
  end
end
