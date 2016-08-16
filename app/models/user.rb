require 'net/http'
require 'json'

# a model representing user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  acts_as_reader
  ROLES = %w(requestor approver release_manager)
  ADMIN = %w(Admin User)
  validates :role, inclusion: { in: ROLES,
                              message: '%{value} is not a valid role' }
  validates :email, presence: true
  has_many :IncidentReports
  has_many :ChangeRequests
  has_and_belongs_to_many :associated_change_requests, join_table: :change_requests_associated_users, class_name: 'ChangeRequest'
  has_and_belongs_to_many :collaborate_change_requests, join_table: :collaborators, class_name: 'ChangeRequest'
  has_and_belongs_to_many :implement_change_requests, join_table: :implementers, class_name: :ChangeRequest
  has_and_belongs_to_many :test_change_requests, join_table: :testers, class_name: :ChangeRequest
  has_many :Comments
  has_many :notifications, dependent: :destroy
  has_many :Approvals, :dependent => :destroy
  validates :email, format: { with: /\b[A-Z0-9._%a-z\-]+@veritrans\.co\.id\z/,
                  message: "must be a veritrans account" }
  validates :email, uniqueness: true
  scope :approvers, -> {where(role: 'approver')}


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
    update_attributes(
      token: data['access_token'],
      expired_at: Time.now + (data['expires_in'].to_i).seconds)
  end

  def expired?
    expired_at < Time.now
  end

  def fresh_token
    refresh! if (expired? || token == nil)
    token
  end

  #refer to https://developers.google.com/oauthplayground and https://github.com/nahi/httpclient/blob/master/sample/howto.rb
  def get_contacts
    client = HTTPClient.new()
    target = 'https://www.google.com/m8/feeds/contacts/default/full/'
    token = 'Bearer ' + self.fresh_token
    response = client.get(target, nil, {'Gdata-version' => '3.0', 'Authorization' => token}).body
    response
    xml = Nokogiri.XML(response)
    all_contact = []
    xml.xpath('//gd:email').each do |entry|
      all_contact.push(entry['address'])
    end
    all_contact
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
    role == 'approver'
  end

  def is_associated?(change_request)
    associated_change_requests.inclide? change_request
  end
end
