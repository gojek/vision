class SlackNotif
  def self.client
    @client ||= Slack::Web::Client.new
  end

  def self.notif_new_request (change_request,link)
    approvers = change_request.approvals.collect{|app| app.user}
    approvers.each do |approver|
      next if approver.slack_username.blank?
      message = "New <#{link}|change request> needs your approvals"
      attachment = {
        fallback: message,
        color: "#439FE0",
        title: change_request.change_summary,
        title_link: link,
        fields: [
          {
            title: "Business Justification",
            value: change_request.business_justification,
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
      self.client.chat_postMessage(channel: "@#{approver.slack_username}", text: message, attachments: [attachment])
    end
  end

  def self.notif_comment_mention(comment, mentionees, link)
    mentionees.each do |mentionee|
      next if mentionee.slack_username.blank?
      attachment = {
        fallback: comment.body,
        text: comment.body,
        color: "#439FE0",
        title: comment.change_request.change_summary,
        title_link: link,
        footer: "VT-Vision",
        ts: comment.created_at.to_datetime.to_f.round
      }
      self.client.chat_postMessage(channel: "@#{mentionee.slack_username}",
        text: "You are mentioned in #{comment.user.name} comment's on <#{link}|change request>", attachments: [attachment])
    end
  end
end
