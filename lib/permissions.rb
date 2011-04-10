module Permissions

  def save_as user_in_question
    check_permissions user_in_question
    save
  end

  def destroy_as user_in_question
    check_permissions user_in_question
    destroy
  end

  private

  def self.included(base)
    base.instance_eval do
      validate :add_permission_errors
    end
  end

  def add_permission_errors
    self.errors[:base].concat(@permission_errors) if @permission_errors.present?
  end

  def check_permissions(user_in_question)
    unless user == user_in_question ||
      # TODO: figure out why user is nil for new samples despite instrument,
      # TODO: being present, has a user. Suspect: has_one :through
      try(:instrument).try(:user) == user_in_question || 
      user_in_question.admin?

      @permission_errors ||= []
      @permission_errors << "Permission denied"
    end
  end

end
