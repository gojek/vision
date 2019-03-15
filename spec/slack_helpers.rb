# frozen_string_literal: true

module SlackHelpers
  def user_lookup_success_stub
    stub_request(:post, 'https://slack.com/api/users.lookupByEmail')
      .with(body: { 'email' => 'patrick@veritrans.co.id', 'token' => /[A-Za-z0-9]*/ })
      .to_return(status: 200,
                 body: '{
                  "ok": true,
                  "user": {
                    "name":"patrick.star",
                    "profile":{
                      "email":"patrick@veritrans.co.id"
                    }
                  }
                }', headers: {})
  end

  def user_lookup_failed_stub
    stub_request(:post, 'https://slack.com/api/users.lookupByEmail')
      .with(body: { 'email' => 'dummy@dummy.com', 'token' => /[A-Za-z0-9]*/ })
      .to_return(status: 200, body: '{"ok": false, "error":"users_not_found"}', headers: {})
  end

  def error_not_found_stub(subject)
    if subject == 'channel'
      stub_request(:post, 'https://slack.com/api/chat.postMessage')
        .to_return(status: 200, body: '{"ok": false, "error":"channel_not_found"}', headers: {})
    elsif subject == 'users'
      stub_request(:post, 'https://slack.com/api/users.lookupByEmail')
        .to_return(status: 200, body: '{"ok": false, "error":"users_not_found"}', headers: {})
    end
  end
end
