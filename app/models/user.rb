class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable
  ROLES = %w(user admin)
  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role"}
  has_many :IncidentReports
  def account_active?
      locked_at.nil?
  end

  def active_for_authentication?
      super && account_active?
  end

  def inactive_message
      account_active? ? super : :locked
  end

end
