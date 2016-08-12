namespace :associated_user do
  desc "Testing populate change requests associated users into the database"
  task :populate_users_dryrun => :environment do
    populate(true)
  end

  desc "Populate change requests associated users into the database"
  task :populate_users => :environment do
    populate(false)
  end

  def populate(is_dryrun)
    puts "This is a dryrun".colorize(:light_red) if is_dryrun
    ChangeRequest.all.each do |cr|
      associated_user_ids = [cr.user.id]
      associated_user_ids.concat(cr.approvals.collect(&:user_id))
      associated_user_ids.concat(cr.implementers.collect(&:id))
      associated_user_ids.concat(cr.testers.collect(&:id))
      associated_user_ids.concat(cr.collaborators.collect(&:id))
      associated_user_ids.uniq!
      puts "Change Requests ##{cr.id} associated users: #{associated_user_ids}".colorize(:light_green)
      if !is_dryrun
        if cr.update(associated_user_ids: associated_user_ids)
          puts "~~> Associated users assigned!".colorize(:light_blue)
        end
      end
    end
  end
end
