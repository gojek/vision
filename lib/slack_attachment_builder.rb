# frozen_string_literal: true

class SlackAttachmentBuilder
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper

  def generate_change_request_attachment(change_request)
    approvers_name = change_request.approvals.includes(:user).pluck(:name)
    {
      fallback: change_request.change_summary,
      color: '#439FE0',
      title: "#{change_request.id}. #{change_request.change_summary}",
      title_link: change_request_url(change_request),
      callback_id: change_request.id,
      fields: [
        {
          title: 'Business Justification',
          value: sanitize(change_request.business_justification, tags: []),
          short: false
        }, {
          title: 'Priority',
          value: change_request.priority,
          short: true
        }, {
          title: 'Scope',
          value: change_request.scope,
          short: true
        }, {
          title: 'Downtime Impact',
          value: change_request_downtime(change_request),
          short: false
        }, {
          title: 'Deployment Time',
          value: change_request.schedule_change_date,
          short: false
        }, {
          title: 'Approvers',
          value: (approvers_name.join ', '),
          short: false
        }
      ],
      footer: 'VT-Vision',
      ts: change_request.created_at.to_datetime.to_f.round
    }
  end

  def generate_simple_change_request_attachment(change_request)
    {
      fallback: change_request.change_summary,
      color: '#439FE0',
      title: "#{change_request.id}. #{change_request.change_summary}",
      title_link: change_request_url(change_request),
      callback_id: change_request.id,
      fields: [
        {
          title: 'Business Justification',
          value: sanitize(change_request.business_justification, tags: []),
          short: false
        }
      ],
      footer: 'VT-Vision',
      ts: change_request.created_at.to_datetime.to_f.round
    }
  end

  def wrap_approver_actions(attachment)
    actionable_attachment = attachment.dup
    actionable_attachment[:actions] = [
      {
        name: 'act',
        text: 'Approve',
        type: 'button',
        style: 'success',
        value: 'approve'
      },
      {
        name: 'act',
        text: 'Reject',
        type: 'button',
        style: 'danger',
        value: 'reject'
      }
    ]

    actionable_attachment
  end

  def generate_comment_attachment(comment)
    change_request = comment.change_request
    {
      fallback: comment.body,
      text: comment.body,
      color: '#439FE0',
      title: change_request.change_summary,
      title_link: change_request_url(change_request),
      footer: 'VT-Vision',
      ts: comment.created_at.to_datetime.to_f.round
    }
  end

  def generate_ar_comment_attachment(ar_comment)
    access_request = ar_comment.access_request
    {
      fallback: ar_comment.body,
      text: ar_comment.body,
      color: '#439FE0',
      title: access_request.employee_name,
      title_link: access_request_url(access_request),
      footer: 'VT-Vision',
      ts: ar_comment.created_at.to_datetime.to_f.round
    }
  end

  def generate_approval_status_cr_attachment(change_request, approval)
    notes = approval.notes
    {
      fallback: change_request.change_summary,
      color: '#439FE0',
      title: "#{change_request.id}. #{change_request.change_summary}",
      title_link: change_request_url(change_request),
      callback_id: change_request.id,
      fields: [
        {
          title: 'Approval Status',
          value: (approval.approve ? 'Approved by' : 'Rejected by') + " #{approval.user.name}",
          short: false
        }, {
          title: 'Note',
          value: notes.to_s,
          short: false
        }
      ],
      footer: 'VT-Vision',
      ts: change_request.created_at.to_datetime.to_f.round
    }
  end

  def generate_incident_report_attachment(incident_report)
    acknowledge_time = if incident_report.acknowledge_time.present?
                         "#{incident_report.acknowledge_time} " \
                         "(#{pluralize(incident_report.time_to_acknowledge_duration.to_i, 'minute')})"
                       else
                         '-'
                       end
    {
      fallback: incident_report.service_impact,
      color: '#439FE0',
      title: "#{incident_report.id}. #{incident_report.service_impact}",
      title_link: incident_report_url(incident_report),
      callback_id: incident_report.id,
      fields: [
        {
          title: 'Source',
          value: incident_report.source,
          short: true
        }, {
          title: 'Level',
          value: incident_report.rank,
          short: true
        }, {
          title: 'Details',
          value: sanitize(incident_report.problem_details, tags: []),
          short: false
        }, {
          title: 'Occurrence Time',
          value: incident_report.occurrence_time,
          short: false
        }, {
          title: 'Acknowledge Time',
          value: acknowledge_time,
          short: false
        }, {
          title: 'Reporter',
          value: incident_report.user.name,
          short: false
        }
      ],
      footer: 'VT-Vision',
      ts: incident_report.created_at.to_datetime.to_f.round
    }
  end

  def generate_access_request_attachment(access_request)
    {
      fallback: access_request.request_type,
      color: '#439FE0',
      title: "#{access_request.id}. #{access_request.employee_name}(#{access_request.employee_department})",
      title_link: access_request_url(access_request),
      callback_id: access_request.id,
      fields: [
        {
          title: 'Access type',
          value: access_request.access_type,
          short: false
        }, {
          title: 'Email',
          value: access_request.employee_email_address,
          short: false
        }
      ],
      footer: 'VT-Vision',
      ts: access_request.created_at.to_datetime.to_f.round
    }
  end

  private

  def change_request_downtime(change_request)
    if change_request.downtime_expected?
      "#{change_request.expected_downtime_in_minutes} minute(s)"
    else
      'No expected Downtime'
    end
  end
end
