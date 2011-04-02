class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :remember_me
  serialize :timezone
  has_many :locations
  has_many :instruments
  has_many :samples, through: :instruments
end
