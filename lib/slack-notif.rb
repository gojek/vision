class SlackNotif
  require 'slack-notifier'

  def self.instance
    @nottifier ||= Slack::Notifier.new "https://hooks.slack.com/services/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"
  end

  def self.notif_new_request (change_request,link)
    self.instance.channel = "@dwiyan"
    message = "New change [request](#{link}) needs your approvals"
    message = Slack::Notifier::LinkFormatter.format(message)
    attachment = {
      fallback: message,
      pretext: "New change request needs your approval",
      color: "#439FE0",
      title: change_request.change_summary,
      title_link: link,
      fields: [
        {
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
    self.instance.ping "", attachments: [attachment]
  end
end
