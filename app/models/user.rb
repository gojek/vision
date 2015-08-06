require 'net/http'
require 'json'

# a model representing user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :lockable, :timeoutable,  
         :omniauthable, omniauth_providers: [:google_oauth2]
  ROLES = %w(requestor approver release_manager)
  validates :role, inclusion: { in: ROLES,
                                message: '%{value} is not a valid role' }
  validates :email, presence: true
  has_many :IncidentReports
  has_many :ChangeRequests
  has_many :Comments
  has_many :Approvers, :dependent => :destroy
  validates :email, format: { with: /\b[A-Z0-9._%a-z\-]+@veritrans\.co\.id\z/,
                  message: "must be a veritrans account" }
  validates :email, uniqueness: true

  def account_active?
    locked_at.nil?
  end

  def active_for_authentication?
    super && account_active?
  end

  def timeout_in
    1.day
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

  def token_to_params
    {'refresh_token' => refresh_token,
    'client_id' => ENV['GOOGLE_API_KEY'],
    'client_secret' => ENV['GOOGLE_API_SECRET'],
    'grant_type' => 'refresh_token'}
  end

  def request_token_from_google
    url = URI('https://accounts.google.com/o/oauth2/token')
    Net::HTTP.post_form(url, self.token_to_params)
  end

  def refresh!
    response = request_token_from_google
    data = JSON.parse(response.body)
    update_attributes(
      token: data['access_token'],
      expired_at: Time.now + (data['expires_in'].to_i).seconds)
  end

  def expired?
    expired_at < Time.now
  end

  def fresh_token
    refresh! if expired?
    token
  end

end
 
