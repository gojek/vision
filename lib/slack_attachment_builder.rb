class SlackAttachmentBuilder
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper

  def generate_change_request_attachment(change_request)
    approvers_name = change_request.approvals.includes(:user).pluck(:name)
    attachment = {
      fallback: change_request.change_summary,
      color: "#439FE0",
      title: "#{change_request.id}. #{change_request.change_summary}",
      title_link: change_request_url(change_request),
      callback_id: change_request.id,
      fields: [
        {
          title: "Business Justification",
          value: sanitize(change_request.business_justification, tags: []),
          short: false
        },{
          title: "Priority",
          value: change_request.priority,
          short: true
        },{
          title: "Scope",
          value: change_request.scope,
          short: true
        },{
          title: "Deployment Time",
          value: change_request.schedule_change_date,
          short: false
        },{
          title: "Approvers",
          value: (approvers_name.join ', '),
          short: false
        }
      ],
      footer: "VT-Vision",
      ts: change_request.created_at.to_datetime.to_f.round
    }
  end

  def wrap_approver_actions(attachment, user)
    actionable_attachment = attachment.dup
    actionable_attachment[:actions] = [
      {
        name: "act",
        text: "Approve",
        type: "button",
        style: "success",
        value: "approve"
      },
       {
        name: "act",
        text: "Reject",
        type: "button",
        style: "danger",
        value: "reject"
      }
    ]

    actionable_attachment
  end

  def generate_comment_attachment(comment)
    change_request = comment.change_request
    attachment = {
      fallback: comment.body,
      text: comment.body,
      color: "#439FE0",
      title: change_request.change_summary,
      title_link: change_request_url(change_request),
      footer: "VT-Vision",
      ts: comment.created_at.to_datetime.to_f.round
    }
  end

end
