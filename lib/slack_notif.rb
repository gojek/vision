class SlackNotif
  def self.client
    @client ||= Slack::Web::Client.new
  end

  def self.notif_new_request (change_request,link)
    approvers = change_request.approvals.collect{|app| app.user}
    approvers.each do |approver|
      if approver.slack_username.blank?
        next if self.search_username(approver) == nil
      end
      message = "New <#{link}|change request> needs your approvals"
      attachment = {
        fallback: message,
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
      self.client.chat_postMessage(channel: "@#{approver.slack_username}", text: message, attachments: [attachment])
    end
  end

  def self.search_username(user)
    self.client.users_list.members.each do |u|
      if user.email == u.profile.email
        user.slack_username = u.name
        return u.name
      end
    end
    return nil
  end
end
