# a model representing user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  ROLES = %w(requestor approver release_manager)
  validates :role, inclusion: { in: ROLES,
                                message: '%{value} is not a valid role' }
  validates :email, presence: true
  has_many :IncidentReports
  has_many :ChangeRequests
  has_many :comments
  validates :email, format: { with: /\b[A-Z0-9._%a-z\-]+@veritrans\.co\.id\z/,
                  message: "must be a veritrans account" }
  validates :email, uniqueness: true

  def account_active?
    locked_at.nil?
  end

  def active_for_authentication?
    super && account_active?
  end

  def self.from_omniauth(auth)
    where(provider: auth[:provider], uid: auth[:uid]).first_or_create do |user|
      user.email = auth[:info][:email]
      user.name = auth[:info][:name]
      user.role = 'requestor'
      user.is_admin = false
    end
  end

  def self.find_version_author(version)
    find(version.terminator)
  end
end
 
