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
    count_success = 0
    count_fail = 0
    ChangeRequest.all.each do |cr|
      associated_user_ids = [cr.user.id]
      associated_user_ids.concat(cr.approvals.collect(&:user_id))
      associated_user_ids.concat(cr.implementers.collect(&:id))
      associated_user_ids.concat(cr.testers.collect(&:id))
      associated_user_ids.concat(cr.collaborators.collect(&:id))
      associated_user_ids.uniq!
      puts "Change Requests ##{cr.id} associated users: #{associated_user_ids}".colorize(:light_green)
      if !is_dryrun
        if cr.update_attributes(associated_user_ids: associated_user_ids)
          puts "~~> Associated users assigned to CR##{cr.id}".colorize(:light_blue)
          count_success += 1
        else
          puts "~~> Failed to assign associated users CR##{cr.id}".colorize(:light_red)
          count_fail += 1
        end
      end
    end
    puts "\n\nRake result:".colorize(:light_blue)
    puts "Succes : #{count_success} change requests".colorize(:light_green)
    puts "Fail   : #{count_fail} change requests".colorize(:light_red)
  end
end
