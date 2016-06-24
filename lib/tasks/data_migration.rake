namespace :data_migration do
  desc "Implementing implementers data migration from old to new design with full name matching"
  task :full_name_match_implementer => :environment do
    full_name_match Implementer.all, false
  end

  desc "Implementing implementers data migration from old to new design with pattern matching"
  task :pattern_match_implementer => :environment do
    pattern_match Implementer.all, false
  end

  desc "Implementing testers data migration from old to new design with full name matching"
  task :full_name_match_tester => :environment do
    full_name_match Tester.all, false
  end

  desc "Implementing testers data migration from old to new design with pattern matching"
  task :pattern_match_tester => :environment do
    pattern_match Tester.all, false
  end

  desc "Testing implementers data migration from old to new design with full name matching"
  task :full_name_match_implementer_dryrun => :environment do
    full_name_match Implementer.all, true
  end

  desc "Testing implementers data migration from old to new design with pattern matching"
  task :pattern_match_implementer_dryrun => :environment do
    pattern_match Implementer.all, true
  end

  desc "Testing testers data migration from old to new design with full name matching"
  task :full_name_match_tester_dryrun => :environment do
    full_name_match Tester.all, true
  end

  desc "Testing testers data migration from old to new design with pattern matching"
  task :pattern_match_tester_dryrun => :environment do
    pattern_match Tester.all, true
  end

  def full_name_match(records, is_dryrun)
    count = 0
    count_success = 0
    #iterating all records
    records.each do |record|
      count = count + 1
      if record.name.blank?
        puts "record #{record.id} name's is blank".colorize(:light_red)
        next
      end

      #matching
      user = User.find_by(name: record.name)
      if user == nil
        puts "#{record.name} is not found".colorize(:light_red)
      else
        puts "#{record.name} is found".colorize(:light_green)
        count_success = count_success + 1
        record.update(user_id: user.id) if !is_dryrun
      end
    end
    puts "Searching #{count} users, #{count_success} found"
  end

  def pattern_match(records, is_dryrun)
    count = 0
    count_multiple_find = 0
    count_success = 0
    #iterating all records
    records.each do |record|
      count = count + 1
      if record.name.blank?
        puts "record #{record.id} name's is blank".colorize(:light_red)
        next
      end

      #generate pattern to be used
      names = ""
      record.name.downcase.split.each do |word|
        if names.blank?
          names = word
        else
          names = names + "% " + word
        end
      end
      #matching
      users = User.where("lower(name) LIKE (?)", "%#{names}%")
      if users.count == 0
        puts "#{record.name} is not found".colorize(:light_red)
      elsif users.count > 1
        puts "#{record.name} found with multiple matching user".colorize(:light_yellow)
        count_multiple_find = count_multiple_find + 1
      else
        puts "#{record.name} is found".colorize(:light_green)
        count_success = count_success + 1
        user = users.first
        record.update(user_id: user.id) if !is_dryrun
      end
    end
    puts "Searching #{count} users, #{count_success} found, #{count_multiple_find} multiple user found"
  end
end
