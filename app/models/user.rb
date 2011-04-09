class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
  attr_accessible :email, :password, :password_confirmation, :remember_me, :real_name
  has_many :locations
  has_many :instruments
  has_many :samples, through: :instruments
  validates_uniqueness_of :screen_name, case_sensitive: false
  validates_format_of :screen_name, with: /\A[-0-9a-zA-Z]+\Z/,
    message: "must only contain letters, numbers and dashes"
  after_create :create_token

  def create_token
    self.reset_authentication_token!
  end

  def timezone=(tz)
    tz &&= case tz
           when ActiveSupport::TimeZone then tz.name
           when String then ActiveSupport::TimeZone.new(tz).try(:name)
           end
    write_attribute :timezone, tz
  end

  def timezone
    tz = read_attribute :timezone
    tz.present? ? ActiveSupport::TimeZone.new(tz) : nil
  end

  def to_param
    screen_name
  end

  def screen_name_matches? screen_name_in_question
    screen_name.casecmp(screen_name_in_question) == 0
  end

  def self.find_by_screen_name screen_name
    first conditions: "lower(screen_name) = '#{screen_name.downcase}'"
  end
end
