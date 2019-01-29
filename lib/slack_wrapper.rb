class SlackWrapper
	def get_slack_username(email)
	    client = Slack::Web::Client.new
	    user = client.users_lookupByEmail('email': email)
	    return user.user.name unless user.nil?
	end
end