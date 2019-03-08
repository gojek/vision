# a model representing user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  acts_as_reader
  ROLES = %w(requestor approver release_manager approver_ar approver_all)
  ADMIN = %w(Admin User)
  LIST_EMAIL_DOMAIN = ENV['VALID_EMAIL'] || "midtrans.com,veritrans.co.id,associate.midtrans.com,spots.co.id,go-jek.com"
  VALID_EMAIL = Regexp.new("\\b[A-Z0-9._%a-z\\-]+@("+LIST_EMAIL_DOMAIN.gsub(/\s+/, '').gsub(',','|').gsub('.','\\.')+")\\z")

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
  has_and_belongs_to_many :collaborate_access_requests, join_table: :access_request_collaborators, class_name: :AccessRequest
  has_and_belongs_to_many :collaborate_change_requests, join_table: :collaborators, class_name: :ChangeRequest
  has_and_belongs_to_many :implement_change_requests, join_table: :implementers, class_name: :ChangeRequest
  has_and_belongs_to_many :test_change_requests, join_table: :testers, class_name: :ChangeRequest
  has_and_belongs_to_many :associated_change_requests, join_table: :change_requests_associated_users, class_name: :ChangeRequest
  has_many :Comments
  has_many :notifications, dependent: :destroy
  has_many :Approvals, :dependent => :destroy

  validates :email, format: { with: VALID_EMAIL,
                  message: "must be a veritrans account" }
  validates :email, uniqueness: true
  scope :approvers, -> {where('role = ? OR role = ?', 'approver', 'approver_all')}
  scope :approvers_ar, -> {where('role = ? OR role = ?', 'approver_ar', 'approver_all')}
  scope :active, -> {where(:locked_at => nil)}


  def account_active?
    locked_at.nil?
  end

  def use_company_email?
    (email =~ VALID_EMAIL).present?
  end

  def active_for_authentication?
    super && account_active?
  end

  def self.from_omniauth(auth)
    user = where("provider = ? AND uid = ? OR email = ?", auth[:provider], auth[:uid], auth[:info][:email]).first
    if user.nil?
      User.transaction do 
        new_user = User.create(
          :email => auth[:info][:email],
          :name => auth[:info][:name],
          :role => DEFAULT_ROLE,
          :is_admin => false,
          :uid => auth[:uid],
          :provider => auth[:provider],
        )
        new_user.slack_username = new_user.get_slack_username
        new_user.save
        return new_user
      end
    else
      user.uid = auth[:uid]
      return user
    end
  end

  def self.find_version_author(version)
    find(version.terminator)
  end
  
  # this will make user logout when google credentials are expired (always 1 hour)
  def expired?
    expired_at < Time.now
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
    change_request.associated_users.include? self
  end

end
