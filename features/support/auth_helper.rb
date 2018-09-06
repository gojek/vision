module AuthHelper
  def login_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:google_oauth2, {
      uid: user.uid,
      credentials: {
        token: "token",
        refresh_token: "refresh_token",
        expires_at: Time.now + 14.days
      }
    })
    visit("/users/auth/google_oauth2")
    OmniAuth.config.test_mode = false
  end
end

World(AuthHelper)
