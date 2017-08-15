class Api::ChangeRequestsController < Api::ApiController
  require 'notifier.rb'

  def action
    payload = JSON.parse params[:payload]
    attachment = payload['original_message']['attachments'][0]
    attachment['actions'] = []

    return head 403 unless payload['token'] == ENV['SLACK_VERIFICATION_TOKEN']

    username     = payload['user']['name']
    cr_id        = payload['callback_id']
  	approved     = payload['actions'][0]['value'] == 'approve'
    action_taken = if approved then 'approved' else 'rejected' end

    user = User.find_by(slack_username: username)
    change_request = ChangeRequest.find_by(id: cr_id)
    
    if change_request.nil?
      attachment['color'] = 'warning'
      return render json: { text: 'Change request not found.', attachments: [attachment] } 
    end

    approval = Approval.find_by(change_request_id: change_request.id, user_id: user.id)

    approval.update(approve: approved, approval_date: Time.current, notes: "#{action_taken.humanize} through Slack")
    Notifier.cr_notify(user, change_request, 'cr_approved')

    attachment['color'] = approved ? 'good' : 'danger'
    message = "You've #{action_taken} this change request"
    render status: 200, json: { text: message, attachments: [attachment] }
  end
end