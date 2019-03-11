module Helpers

  def auth_stub
    stub_request(:post, 'https://oauth2.googleapis.com/token')
      .to_return(status: 200, body: JSON.dump({
          access_token: "token-1234",
          expires_in: 3600,
          scope: "scope-scope",
          token_type: "Bearer",
          id_token: "id-token"
      }), headers: {
          content_type: 'application/json'
      })
  end

  def save_event_error_stub
    stub_request(:post, 'https://www.googleapis.com/calendar/v3/calendars/midtrans.com_7v5rlhrr73t6mj12ifubmst1m0@group.calendar.google.com/events?sendNotifications=true')
      .to_return(status: 403, body: '{\n \"error\": {\n  \"errors\": [\n   {\n    \"domain\": \"calendar\",\n    \"reason\": \"requiredAccessLevel\",\n    \"message\": \"You need to have writer access to this calendar.\"\n   }\n  ],\n  \"code\": 403,\n  \"message\": \"You need to have writer access to this calendar.\"\n }\n}', headers: {
        content_type: 'application/json'
      })
  end

  def save_event_success_stub
    stub_request(:post, 'https://www.googleapis.com/calendar/v3/calendars/midtrans.com_7v5rlhrr73t6mj12ifubmst1m0@group.calendar.google.com/events?sendNotifications=true')
      .to_return(status: 200, body: '{\n \"kind\": \"calendar#event\",\n \"etag\": \"\\\"3102184802480000\\\"\",\n \"id\": \"mupnql7hnt12t73sgvv1n3gfo4\",\n \"status\": \"confirmed\",\n \"htmlLink\": \"https://www.google.com/calendar/event?eid=bXVwbnFsN2hudDEydDczc2d2djFuM2dmbzQgbWlkdHJhbnMuY29tXzd2NXJsaHJyNzN0Nm1qMTJpZnVibXN0MW0wQGc\",\n \"created\": \"2019-02-25T11:00:01.000Z\",\n \"updated\": \"2019-02-25T11:00:01.240Z\",\n \"summary\": \"Change 1\",\n \"description\": \"CR: http://localhost:3003/change_requests/23\\nPIC: Rizqy Faishal Tanjung\",\n \"creator\": {\n  \"email\": \"rizqy.tanjung@midtrans.com\"\n },\n \"organizer\": {\n  \"email\": \"midtrans.com_7v5rlhrr73t6mj12ifubmst1m0@group.calendar.google.com\",\n  \"displayName\": \"staging vision\",\n  \"self\": true\n },\n \"start\": {\n  \"dateTime\": \"2019-01-10T10:58:00+07:00\"\n },\n \"end\": {\n  \"dateTime\": \"2019-01-24T15:17:00+07:00\"\n },\n \"iCalUID\": \"mupnql7hnt12t73sgvv1n3gfo4@google.com\",\n \"sequence\": 0,\n \"attendees\": [\n  {\n   \"email\": \"14@veritrans.co.id\",\n   \"responseStatus\": \"needsAction\"\n  },\n  {\n   \"email\": \"rizqy.tanjung@midtrans.com\",\n   \"responseStatus\": \"needsAction\"\n  },\n  {\n   \"email\": \"1@veritrans.co.id\",\n   \"responseStatus\": \"needsAction\"\n  }\n ],\n \"hangoutLink\": \"https://meet.google.com/qgq-ojki-sjx\",\n \"conferenceData\": {\n  \"createRequest\": {\n   \"requestId\": \"lh5kg98263e09dhasrc99m128k\",\n   \"conferenceSolutionKey\": {\n    \"type\": \"hangoutsMeet\"\n   },\n   \"status\": {\n    \"statusCode\": \"success\"\n   }\n  },\n  \"entryPoints\": [\n   {\n    \"entryPointType\": \"video\",\n    \"uri\": \"https://meet.google.com/qgq-ojki-sjx\",\n    \"label\": \"meet.google.com/qgq-ojki-sjx\"\n   },\n   {\n    \"regionCode\": \"US\",\n    \"entryPointType\": \"phone\",\n    \"uri\": \"tel:+1-304-609-2562\",\n    \"label\": \"+1 304-609-2562\",\n    \"pin\": \"710705355\"\n   }\n  ],\n  \"conferenceSolution\": {\n   \"key\": {\n    \"type\": \"hangoutsMeet\"\n   },\n   \"name\": \"Hangouts Meet\",\n   \"iconUri\": \"https://lh5.googleusercontent.com/proxy/bWvYBOb7O03a7HK5iKNEAPoUNPEXH1CHZjuOkiqxHx8OtyVn9sZ6Ktl8hfqBNQUUbCDg6T2unnsHx7RSkCyhrKgHcdoosAW8POQJm_ZEvZU9ZfAE7mZIBGr_tDlF8Z_rSzXcjTffVXg3M46v\"\n  },\n  \"conferenceId\": \"qgq-ojki-sjx\",\n  \"signature\": \"AGLIgUpxpCqN/e9Yb3Bq7lsDLQFD\"\n },\n \"reminders\": {\n  \"useDefault\": true\n }\n}\n"', headers: {
        content_type: 'application/json'
      });
  end

  def google_oauth_login_mock(user, request)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      :provider => 'google_oauth2',
      :uid => '123545',
      :info => {
        :email => user.email,
        :name => user.name
      }
    })
    
  end
end
