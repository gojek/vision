namespace :data_migration do
  desc "Implementing implementers data migration from old to new design with full name matching"
  task :full_name_match_implementer => :environment do
    count = 0
    count_success = 0
    #iterating all implementer records
    Implementer.all.each do |implementer|
      count = count + 1
      puts "#{count}. Searching user with name #{implementer.name}"
      #matching
      user = User.find_by(name: implementer.name)
      if user == nil
        puts 'User is not found'
      else
        puts 'User is found'
        count_success = count_success + 1

        implementer.user_id = user.id
        implementer.save
      end
    end
    puts "Searching #{count} users, #{count_success} found"
  end

  desc "Implementing implementers data migration from old to new design with pattern matching"
  task :pattern_match_implementer => :environment do
    count = 0
    count_multiple_find = 0
    count_success = 0
    #iterating all implementer records
    Implementer.all.each do |implementer|
      count = count + 1
      puts "#{count}. Searching user with name #{implementer.name}"
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
        puts 'User is not found'
      elsif users.count > 1
        puts 'Multiple users are found'
        count_multiple_find = count_multiple_find + 1
      else
        puts 'User is found'
        count_success = count_success + 1

        user = users.first
        implementer.user_id = user.id
        implementer.save
      end
    end
    puts "Searching #{count} users, #{count_success} found, #{count_multiple_find} multiple user found"
  end

  desc "Implementing testers data migration from old to new design with full name matching"
  task :full_name_match_tester => :environment do
    count = 0
    count_success = 0
    #iterating all implementer records
    Tester.all.each do |tester|
      count = count + 1
      puts "#{count}. Searching user with name #{tester.name}"
      #matching
      user = User.find_by(name: tester.name)
      if user == nil
        puts 'User is not found'
      else
        puts 'User is found'
        count_success = count_success + 1

        tester.user_id = user.id
        tester.save
      end
    end
    puts "Searching #{count} users, #{count_success} found"
  end

  desc "Implementing testers data migration from old to new design with pattern matching"
  task :pattern_match_tester => :environment do
    count = 0
    count_multiple_find = 0
    count_success = 0
    #iterating all tester records
    Tester.all.each do |tester|
      count = count + 1
      puts "#{count}. Searching user with name #{tester.name}"
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
        puts 'User is not found'
      elsif users.count > 1
        puts 'Multiple users are found'
        count_multiple_find = count_multiple_find + 1
      else
        puts 'User is found'
        count_success = count_success + 1

        user = users.first
        tester.user_id = user.id
        tester.save
      end
    end
    puts "Searching #{count} users, #{count_success} found, #{count_multiple_find} multiple user found"
  end
end
