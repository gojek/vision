require 'net/http'
require 'json'

# a model representing user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  acts_as_reader

  ROLES = %w(requestor approver release_manager approver_ar approver_all)
  ADMIN = %w(Admin User)

  APPROVER_EMAIL = ENV['APPROVER_EMAIL'] || 'ika.​muiz@midtrans.​com'
  DEFAULT_APPROVED_STATUS = 1
  DEFAULT_ROLE = 'requestor'

  # is_approved status
  REJECTED = 0
  NOT_YET_FILL_THE_FORM = 1
  WAITING_FOR_APPROVAL = 2
  APPROVED = 3

  validates :role, inclusion: { in: ROLES,
                              message: '%{value} is not a valid role' }
  validates :email, presence: true
  has_many :IncidentReports
  has_many :ChangeRequests
  has_many :AccessRequests
  has_and_belongs_to_many :associated_change_requests, join_table: :change_requests_associated_users, class_name: 'ChangeRequest'
  has_and_belongs_to_many :collaborate_change_requests, join_table: :collaborators, class_name: 'ChangeRequest'
  has_and_belongs_to_many :implement_change_requests, join_table: :implementers, class_name: :ChangeRequest
  has_and_belongs_to_many :test_change_requests, join_table: :testers, class_name: :ChangeRequest
  has_many :Comments
  has_many :notifications, dependent: :destroy
  has_many :Approvals, :dependent => :destroy
  validates :email, format: { with: /\b[A-Z0-9._%a-z\-]+@(veritrans\.co\.id|midtrans\.com|associate\.midtrans\.com||spots\.co\.id)\z/,
                  message: "must be a veritrans account" }
  validates :email, uniqueness: true
  scope :approvers, -> {where('role = ? OR role = ?', 'approver', 'approver_all')}
  scope :approvers_ar, -> {where('role = ? OR role = ?', 'approver_ar', 'approver_all')}
  scope :active, -> {where(:locked_at => nil)}


  def account_active?
    locked_at.nil? && (is_approved == APPROVED || is_approved == NOT_YET_FILL_THE_FORM)
  end

  def use_company_email?
    (email =~ /\b[A-Z0-9._%a-z\-]+@(veritrans\.co\.id|midtrans\.com|associate\.midtrans\.com |spots\.co\.id)\z/).present?
  end

  def active_for_authentication?
    super && account_active?
  end

  def inactive_message
    account_active? ? super : (is_approved == REJECTED ? "Sorry, your access request to Vision is rejected." : 
                                                         "Your account is not yet approved to open Vision")
  end

  def self.from_omniauth(auth)
    user = where(provider: auth[:provider], uid: auth[:uid]).first
    if user.nil?
      User.transaction do 
        new_user = User.create(
          :email => auth[:info][:email],
          :name => auth[:info][:name],
          :role => DEFAULT_ROLE,
          :is_admin => false,
          :is_approved => DEFAULT_APPROVED_STATUS,
          :uid => auth[:uid],
          :provider => auth[:provider],
        )
        new_user.slack_username = new_user.get_slack_username,
        new_user.save
        return new_user
      end
    else
      return user
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
    logger.info("Got This from Response: #{data.inspect}" )
    update_attributes(
      token: data['access_token'],
      expired_at: Time.now + (data['expires_in'].to_i).seconds
    )
  end

  # this will make user logout when google credentials are expired (always 1 hour)
  def expired?
    expired_at < Time.now
  end

  def expired_session?
    (expired_at + 7.days) < Time.now
  end

  def fresh_token
    refresh! if (expired? || token == nil)
    token
  end

  def get_slack_username
    client = Slack::Web::Client.new
    client.users_list.members.each do |u|
      if email == u.profile.email
        return u.name
      end
    end
    nil
  end
  def have_notifications?
    (notifications.cr.count != 0 || notifications.ir.count != 0)
  end

  def is_approver?
    ['approver', 'approver_all'].include?(role)
  end

  def is_associated?(change_request)
    associated_change_requests.include? change_request
  end
end
