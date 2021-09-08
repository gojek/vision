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
    stub_request(:post, 'https://www.googleapis.com/calendar/v3/calendars/x@group.calendar.google.com/events?sendNotifications=true')
      .to_return(status: 200, body: JSON.dump({
        kind: "calendar#event",
        etag: "3102184802480000",
        id: "mupnql7hnt12t73sgvv1n3gfo4",
        status: "confirmed",
        htmlLink: "https://www.google.com/calendar/event?eid=bXVwbnFsN2hudDEydDczc2d2djFuM2dmbzQgbWlkdHJhbnMuY29tXzd2NXJsaHJyNzN0Nm1qMTJpZnVibXN0MW0wQGc",
        created: "2019-02-25T11:00:01.000Z",
        updated: "2019-02-25T11:00:01.240Z",
        summary: "Change 1",
        description: "CR: http://localhost:3000/change_requests/23, PIC: Rizqy Faishal Tanjung",
        creator: {
          email: "rizqy.tanjung@midtrans.com"
        },
        organizer: {
          email: "midtrans.com_7v5rlhrr73t6mj12ifubmst1m0@group.calendar.google.com"
        },
        displayName: "staging vision",
        self: true,
        start: {
          dateTime: "2019-01-10T10:58:00+07:00"
        },
        end: {
          dateTime: "2019-01-24T15:17:00+07:00"
        },
        iCalUID: "mupnql7hnt12t73sgvv1n3gfo4@google.com",
        sequence: 0,
        attendees: [
          {
            email: "14@veritrans.co.id",
            responseStatus: "needsAction"
          },
          {
            email: "rizqy.tanjung@midtrans.com",
            responseStatus: "needsAction"
          },
          {
            email: "1@veritrans.co.id",
            responseStatus: "needsAction"
          },
        ],
        hangoutLink: "https://meet.google.com/qgq-ojki-sjx",
        conferenceData: {
          createRequest: {
            requestId: "lh5kg98263e09dhasrc99m128k",
            conferenceSolutionKey: {
              type: "hangoutsMeet"
            },
            status: {
              statusCode: "success"
            }
          }
        }
      }), headers: {
        content_type: 'application/json'
      })
  end

  def google_oauth_login_mock(user)
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
