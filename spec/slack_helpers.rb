# frozen_string_literal: true

module SlackHelpers
  def user_success_stub
    stub_request(:post, 'https://slack.com/api/users.lookupByEmail')
      .with(body: { 'email' => 'patrick@veritrans.co.id', 'token' => nil })
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

  def user_failed_stub
    stub_request(:post, 'https://slack.com/api/users.lookupByEmail')
      .with(body: { 'email' => 'dummy@dummy.com', 'token' => nil })
      .to_return(status: 200, body: '{"ok": false, "error":"users_not_found"}', headers: {})
  end
end
