# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = []
(1..15).each do |i|
  user[i] = User.new(email: "email.user#{i}@veritrans.co.id", role: "approver")
end
user[1].name = "Tatang Seekor Nyamuk"
user[2].name = "Budi Santoso"
user[3].name = "Karla Lulu Lava"
user[4].name = "Lala Lulu Lovo"
user[5].name = "Saya Lapar Log"
user[6].name = "Sudirman Duniarjo"
user[7].name = "John Van Bejo"
user[8].name = "Julaeha Princess"
user[9].name = "Maman Sukaman Temanteman"
user[10].name = "Jack Hogan"
user[11].name = "James Bond"
user[12].name = "Peter Parker"
user[13].name = "Robert Dawney"
user[14].name = "Harry Potter"
user[15].name = "Aragorn Arathorn"

(1..15).each do |i|
  user[i].save
end

cr = ChangeRequest.new(user: user[1])
cr.save(validate: false)
Approval.create(user: user[1], change_request: cr)

Implementer.create(name: "Tatang Nyamuk", change_request: cr)
Implementer.create(name: "Budi Santoso", change_request: cr)
Implementer.create(name: "Lulu L", change_request: cr)
Implementer.create(name: "Saya Lapar", change_request: cr)
Implementer.create(name: "S Duniarjo", change_request: cr)
Implementer.create(name: "John B", change_request: cr)
Implementer.create(name: "Princess", change_request: cr)
Implementer.create(name: "Sukaman", change_request: cr)
Implementer.create(name: "Jack H", change_request: cr)
Implementer.create(name: "Peter Parker", change_request: cr)
Implementer.create(name: "James B", change_request: cr)
Implementer.create(name: "Peter P", change_request: cr)
Implementer.create(name: "R Dawney", change_request: cr)
Implementer.create(name: "Harry Poter", change_request: cr)
Implementer.create(name: "Aragorn Arathorn Anton", change_request: cr)
