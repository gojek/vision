class Api::ChangeRequestsController < Api::ApiController
  require 'notifier.rb'

  def action
    payload = JSON.parse params[:payload]

    return head 403 unless payload['token'] == ENV['SLACK_VERIFICATION_TOKEN']

    username     = payload['user']['name']
    cr_id        = payload['callback_id']
  	value        = payload['actions'][0]['value']

    user = User.find_by(slack_username: username)
    change_request = ChangeRequest.find(cr_id)
    approval = Approval.find_by(change_request_id: change_request.id, user_id: user.id)

    approval.update(approve: value == 'approve', approval_date: Time.current, notes: 'Approved through Slack')
    Notifier.cr_notify(user, change_request, 'cr_approved')

    attachment = payload['original_message']['attachments'][0]
    attachment['actions'] = []
    message = "You've #{value}ed this change request"
    render status: 200, json: { text: message, attachments: [attachment] }
  end
end