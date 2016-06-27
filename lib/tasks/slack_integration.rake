namespace :slack_integration do
  desc "Search and populate user slack username's into the database with slack API"
  task :populate_username => :environment do
    client = Slack::Web::Client.new
    slack_usernames = {}
    client.users_list.members.each do |u|
      slack_usernames[u.profile.email] = u.name
    end

    User.all.each do |user|
      if (slack_username = slack_usernames[user.email]) != nil
        user.slack_username = slack_username
        user.save
      end
    end
  end
end
