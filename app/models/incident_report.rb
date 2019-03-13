# a model representating incident report document
class IncidentReport < ActiveRecord::Base
  include ActiveModel::Dirty
  
  belongs_to :user
  has_and_belongs_to_many :collaborators, join_table: :incident_report_collaborators, class_name: 'User'
  has_many :logs, join_table: :access_request_logs, dependent: :destroy, class_name: 'IncidentReportLog'

  before_save :create_incident_report_log, :unless => :new_record?
  before_save :set_recovery_duration, :if => :resolved_time?
  before_update :set_recovery_duration

  before_save :set_current_status
  before_update :set_current_status

  before_save :set_action_item_done_time, if: :action_item_status_done?
  before_save :set_time_to_acknowledge_duration, :if => :acknowledge_time?
  before_update :set_time_to_acknowledge_duration

  acts_as_readable :on => :updated_at
  has_paper_trail class_name: 'IncidentReportVersion',
                  meta: { author_username: :user_name }
  acts_as_taggable
  CURRENT_STATUS = %w(Ongoing Acknowledged Resolved)
  MEASURER_STATUS = %w(Implemented Development)
  SOURCE = %w(Internal External)
  RECURRENCE_CONCERN = %w(Low Medium High)
  ACTION_ITEM_STATUS = ['In Progress', 'Done']
  ENTITY_SOURCES = ENV['ENTITY_SOURCES'].split(",").map!(&:titleize) || []

  has_many :notifications, dependent: :destroy
  validates :service_impact, :problem_details, :how_detected, :occurrence_time,
            :detection_time, :loss_related, :occurred_reason,
            :overlooked_reason, :recovery_action, :prevent_action,
            presence: true
  validates :measurer_status, presence: true,
            inclusion: { in: MEASURER_STATUS, message: '%{ value } is not a valid status' }
  validates :source, presence: true,
            inclusion: { in: SOURCE, message: '%{ value } is not a valid source'}
  validates :recurrence_concern, presence: true,
            inclusion: { in: RECURRENCE_CONCERN, message: '%{ value } is not a valid value' }
  validates :rank, presence: true, inclusion: { in: 1..5, message: '%{ value } is not a valid value' }
  validates :action_item_status, presence: true,
            inclusion: { in: ACTION_ITEM_STATUS, message: '%{ value } is not a valid value' },
            if: :has_further_action
  validates :action_item, presence: true, if: :has_further_action

  # recovery and resolve may be the same, but it does not necessarily to be like that
  # recovery is temporary solution, resolved is life-time solution
  validate  :validate_detection_time
  validate  :validate_acknowledge_time, if: :acknowledge_time?
  validate  :validate_resolve_time, if: :resolved_time?
  validates :entity_source, presence: true

  attr_accessor :editor
  attr_accessor :reason

  searchable do
    text :service_impact, stored: true
    text :problem_details, stored: true
    text :how_detected, stored: true
    text :loss_related, stored: true
    text :occurred_reason, stored: true
    text :overlooked_reason, stored: true
    text :recovery_action, stored: true
    text :prevent_action, stored: true
    time :created_at, stored: true
  end

  comma do
    id     
    service_impact 'service impact'     
    problem_details 'problem details' do |problem_details| Sanitize.fragment(problem_details) end
    current_status 'current status' 
    rank     
    measurer_status 'measurer status'     
    recurrence_concern 'recurrence concern'     
    occurrence_time to_s: 'occurrence time'     
    detection_time to_s: 'detection time'     
    acknowledge_time to_s: 'acknowledge time'     
    recovery_duration to_s: 'recovery duration'     
    resolved_time 'resolved time'     
    how_detected 'how was problem detected'     
    loss_related 'loss related issue'
    source 'source'
  end

  def user_name
    user ? user.name : ''
  end

  def check_status
    self.current_status_changed?(from: nil, to: "Resolved") || self.current_status_changed?(from: "Acknowledged", to: "Resolved") || self.current_status_changed?(from: "Ongoing", to: "Resolved")
  end

  def final_status
    return 'N/A' if !has_further_action?
    return 'Done' if action_item_status_done?
    elapsed_time = Time.now - self.occurrence_time
    return 'Warning' if elapsed_time < 2.weeks
    return 'Danger'
  end

  def action_item_status_done?
    self.action_item_status == 'Done'
  end

  def set_action_item_done_time
    self.action_item_done_time = DateTime.now
  end

  def set_recovery_duration
    if resolved_time.nil?
      self.recovery_duration = nil
    else
      self.recovery_duration = (self.resolved_time-self.detection_time)/60
    end
  end

  def set_time_to_acknowledge_duration
    if acknowledge_time.nil?
      self.time_to_acknowledge_duration = nil
    else
      self.time_to_acknowledge_duration = (self.acknowledge_time - self.detection_time)/60
    end
  end


  def validate_acknowledge_time
    if occurrence_time.nil? ||
        detection_time.nil? ||
        !(acknowledge_time >= occurrence_time && acknowledge_time >= detection_time)
      errors.add(:acknowledge_time, "is invalid")
    end
  end

  def validate_resolve_time
    if occurrence_time.nil? || detection_time.nil? || acknowledge_time.nil? ||
        !(resolved_time > occurrence_time && resolved_time > detection_time && resolved_time > acknowledge_time)
      errors.add(:resolved_time, "is invalid")
    end
  end

  def validate_detection_time
    if occurrence_time.nil? || detection_time.nil? || !(detection_time >= occurrence_time)
      errors.add(:detection_time, "is invalid")
    end
  end

  def set_current_status
    if !self.resolved_time.blank?
      self.current_status = "Resolved"
    elsif !self.acknowledge_time.blank?
      self.current_status = "Acknowledged"
    else
      self.current_status = "Ongoing"
    end
  end

  def previous
   IncidentReport.where("id > ?",id).first
  end

  def next
    IncidentReport.where("id < ?",id).last
  end

  def expected=(val)
    if [TrueClass, FalseClass].include?(val)
      write_attribute :expected, val
    else
      write_attribute :expected, (val.to_i == 1)
    end
  end

  def editable?(user)
    return (self.user == user) || user.is_admin || (self.collaborators.include? user)
  end

  def create_incident_report_log
    log = self.logs.new(:user => self.editor, :reason => self.reason)
    unless log.valid?
      errors[:reason] << log.errors[:reason]
      return false
    end
  end

end
