class SlackAttachmentBuilder
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper

  def generate_change_request_attachment(change_request)
    attachment = {
      fallback: change_request.change_summary,
      color: "#439FE0",
      title: change_request.change_summary,
      title_link: change_request_url(change_request),
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
        },
      ],
      footer: "VT-Vision",
      ts: change_request.created_at.to_datetime.to_f.round
    }
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
