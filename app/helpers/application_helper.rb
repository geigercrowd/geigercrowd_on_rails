module ApplicationHelper
  def timezone
    (current_user.try(:timezone) || Time.zone).to_s.sub(/\(.*\) /, '')
  end
end
