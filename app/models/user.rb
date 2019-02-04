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
  validates :role, inclusion: { in: ROLES,
                              message: '%{value} is not a valid role' }
  validates :email, presence: true
  has_many :IncidentReports
  has_many :ChangeRequests
  has_many :AccessRequests
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
    locked_at.nil?
  end

  def use_company_email?
    (email =~ /\b[A-Z0-9._%a-z\-]+@(veritrans\.co\.id|midtrans\.com|associate\.midtrans\.com |spots\.co\.id)\z/).present?
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
      user.slack_username = user.get_slack_username
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
    User.associated_users(change_request).include? self
  end

  def self.associated_users(change_request)
    User.where("id IN (?)",  
      Array.wrap(
        [change_request.user_id] +
        change_request.collaborator_ids +
        change_request.tester_ids +
        change_request.implementer_ids +
        change_request.approvals.collect(&:user_id).to_a
      ).uniq
    )
  end

end
