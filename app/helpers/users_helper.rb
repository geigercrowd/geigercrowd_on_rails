module UsersHelper
  def admin?
    current_user.try(:admin?)
  end
end
