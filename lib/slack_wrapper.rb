class SlackWrapper
	def get_slack_username(email)
	    client = Slack::Web::Client.new
	    begin
	    	user = client.users_lookupByEmail('email': email)
	    	return user.user.name
	    rescue Exception => e
	    	return nil
	    end
	end
end