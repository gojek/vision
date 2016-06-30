Before('@login') do
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:google_oauth2, {
    uid: '12345',
    info: {
      name: 'Mohamad Dwiyan Rahmanianto',
      email: 'mohamad.rahmanianto@***REMOVED***'
    },
    credentials: {
      token: "token",
      refresh_token: "refresh_token",
      expires_at: Time.now + 1.hour
    }
  })
end

After('@login') do
  OmniAuth.config.test_mode = false
end
