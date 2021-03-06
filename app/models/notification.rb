class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :access_request, optional: true
  belongs_to :change_request, optional: true
  belongs_to :incident_report, optional: true
  
  scope :cr, -> { where(:incident_report_id => nil, :access_request_id => nil) }
  scope :new_cr, -> {where(:message => 'new_cr')}
  scope :update_cr, -> {where(:message => 'update_cr')}
  scope :approved, ->{where(:message => 'cr_approved')}
  scope :rejected, ->{where(:message => 'cr_rejected')}
  scope :final_rejected, ->{where(:message => 'cr_final_rejected')}
  scope :cancelled, ->{where(:message => 'cr_cancelled')}
  scope :scheduled, ->{where(:message => 'cr_scheduled')}
  scope :deployed, ->{where(:message => 'cr_deployed')}
  scope :closed, ->{where(:message => 'cr_closed')}
  scope :rollbacked, ->{where(:message => 'cr_rollbacked')}
  scope :comment, ->{where(:message => 'comment_cr')}

  scope :ar, -> { where(:change_request_id => nil, :incident_report_id => nil) }
  scope :ar_comment, ->{ where(:message => 'comment_ar')}
  scope :new_ar, -> { where(:message => 'new_ar') }

  scope :ir, -> { where(:change_request_id => nil, :access_request_id => nil) }
  scope :new_incident, ->{where(:message => 'new_ir')}
  scope :resolved, ->{where(:message => 'resolved_ir')}
end
