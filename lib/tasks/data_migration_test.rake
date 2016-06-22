namespace :data_migration_test do
  desc "Testing implementers data migration from old to new design with full name matching"
  task :full_name_match_implementer => :environment do
    count = 0
    count_success = 0
    #iterating all implementer records
    Implementer.all.each do |implementer|
      count = count + 1
      #matching
      user = User.find_by(name: implementer.name)
      if user == nil
        puts "#{implementer.name} is not found".colorize(:light_red)
      else
        puts "#{implementer.name} is found".colorize(:light_green)
        count_success = count_success + 1
      end
    end
    puts "Searching #{count} users, #{count_success} found"
  end

  desc "Testing implementers data migration from old to new design with pattern matching"
  task :pattern_match_implementer => :environment do
    count = 0
    count_multiple_find = 0
    count_success = 0
    #iterating all implementer records
    Implementer.all.each do |implementer|
      count = count + 1
      #generate pattern to be used
      names = ""
      implementer.name.downcase.split.each do |word|
        if names.blank?
          names = word
        else
          names = names + "% " + word
        end
      end
      #matching
      users = User.where("lower(name) LIKE (?)", "%#{names}%")
      if users.count == 0
        puts "#{implementer.name} is not found".colorize(:light_red)
      elsif users.count > 1
        puts "#{implementer.name} found with multiple matching user".colorize(:light_yellow)
        count_multiple_find = count_multiple_find + 1
      else
        puts "#{implementer.name} is found".colorize(:light_green)
        count_success = count_success + 1
      end
    end
    puts "Searching #{count} users, #{count_success} found, #{count_multiple_find} multiple user found"
  end

  desc "Testing testers data migration from old to new design with full name matching"
  task :full_name_match_tester => :environment do
    count = 0
    count_success = 0
    #iterating all tester records
    Tester.all.each do |tester|
      count = count + 1
      #matching
      user = User.find_by(name: tester.name)
      if user == nil
        puts "#{tester.name} is not found".colorize(:light_red)
      else
        puts "#{tester.name} is found".colorize(:light_green)
        count_success = count_success + 1
      end
    end
    puts "Searching #{count} users, #{count_success} found"
  end

  desc "Testing testers data migration from old to new design with pattern matching"
  task :pattern_match_tester => :environment do
    count = 0
    count_multiple_find = 0
    count_success = 0
    #iterating all tester records
    Tester.all.each do |tester|
      count = count + 1
      #generate pattern to be used
      names = ""
      tester.name.downcase.split.each do |word|
        if names.blank?
          names = word
        else
          names = names + "% " + word
        end
      end
      #matching
      users = User.where("lower(name) LIKE (?)", "%#{names}%")
      if users.count == 0
        puts "#{tester.name} is not found".colorize(:light_red)
      elsif users.count > 1
        puts "#{tester.name} found with multiple matching user".colorize(:light_yellow)
        count_multiple_find = count_multiple_find + 1
      else
        puts "#{tester.name} is found".colorize(:light_green)
        count_success = count_success + 1
      end
    end
    puts "Searching #{count} users, #{count_success} found, #{count_multiple_find} multiple user found"
  end
end
