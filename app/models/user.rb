class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :locations
  has_many :instruments
  has_many :samples, through: :instruments
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
end
