namespace :transfer_user_email do
  desc "Transfer all user"
  task transfer: :environment do
    CSV.foreach("transfer_email.csv",headers: true, col_sep: ',') do |row|
      data = row.to_h
      u = User.find_by_email(data['old_email'])
      u.update('email':data['new_email'])
    end
  end
end
