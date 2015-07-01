# a model representing user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  ROLES = %w(user admin)
  validates :role, inclusion: { in: ROLES,
                                message: '%{value} is not a valid role' }
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

  def self.from_omniauth(auth)
    where(provider: auth[:provider], uid: auth[:uid]).first_or_create do |user|
      user.email = auth[:info][:email]
      user.name = auth[:info][:name]
      user.role = 'user'
    end
  end

  def self.find_version_author(version)
    find(version.terminator)
  end
end
