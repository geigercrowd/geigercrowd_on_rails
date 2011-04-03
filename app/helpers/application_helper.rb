module ApplicationHelper
  def timezone
    current_user.timezone || Time.zone
  end
end
