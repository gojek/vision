namespace :vision do
  desc "Seed approver"
  namespace :approver do
    task seed: :environment do
      name = ENV['name']
      email = ENV['email']

      if name == nil 
        puts "please assign name with param (e.g name=john)"
      end
      
      if email == nil 
        puts "please assign email with param (e.g email=john@example.com)"
      end

      User.find_or_create_by(
        name: name,
        email: email,
        role: "approver",
        is_approved: 3,
        is_admin: 1
      )

      puts "Seed approver success"
    end
  end
  

end
