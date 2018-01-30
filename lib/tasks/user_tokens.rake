namespace :user_tokens do

  desc "Extend user session"
  task :refresh => :environment do
    User.where("current_sign_in_at > ? AND expired_at < ?", 2.days.ago, 30.minutes.from_now).each do |user|
      begin
        puts "Refreshing token for #{user.email} (ID: #{user.id})"
        user.refresh!
        puts "Done"
      rescue => error
        puts "#{error.class}: #{error.message}"
        puts error.backtrace
      end
    end
  end

end