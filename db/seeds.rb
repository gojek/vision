# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.create(email: "1@veritrans.co.id", role: "requestor", name: "Rani Utami")
User.create(email: "12@veritrans.co.id", role: "requestor", name: "Ariq")
User.create(email: "13@veritrans.co.id", role: "requestor", name: "Ya Keu Leus")
User.create(email: "14@veritrans.co.id", role: "requestor", name: "Thisis Aseed")
User.create(email: "15@veritrans.co.id", role: "requestor", name: "Thisisal Soseed")
User.create(email: "16@veritrans.co.id", role: "requestor", name: "Lutfi K P di Veritrans")
User.create(email: "17@veritrans.co.id", role: "requestor", name: "Seorang Requestor")

user = []
(1..20).each do |i|
  user[i] = User.new(email: "email#{i}@veritrans.co.id", role: "requestor")
end

user[1].name = "Nayana Tara Reng Kyu"
user[2].name = "Rinarudi Andurian"
user[3].name = "Giburan Sanchez"
user[4].name = "Azhari von Der Wick"
user[5].name = "John China"
user[6].name = "Reddit Tamasya"
user[7].name = "Pingu Pingi"
user[8].name = "Lahan Peqerjaan"
user[9].name = "Pertalite Debest"
user[10].name = "Michael Mikaelah"
user[11].name = "Bruce Bigotry"
user[12].name = "Lahma Miripin"
user[13].name = "Random Name"
user[14].name = "Slayer bin Ibnu Abbas"
user[15].name = "Riomu Liario"
user[16].name = "Lutfi Kp Lagi Cuy"
user[17].name = "Mang Apark"
user[18].name = "Mang Afox"
user[19].name = "Mang Awan"
user[20].name = "Tuhan Takur"

(1..20).each do |i|
  user[i].save
end

cr = ChangeRequest.new(user: user[3], entity_source: 'midtrans')
cr.save(validate: false)

Tester.create(name: "Mohamad Dwiyan Rahmanianto", change_request: cr)
Tester.create(name: "Nayana Tara", change_request: cr)
Tester.create(name: "Ya Leus", change_request: cr)
Tester.create(name: "Thisis AsEed", change_request: cr)
Tester.create(name: "Lahan P", change_request: cr)
Tester.create(name: "L K L C", change_request: cr)
Tester.create(name: "M Apark", change_request: cr)
Tester.create(name: "Mang Af0x", change_request: cr)
Tester.create(name: "M ang Aw an", change_request: cr)
Tester.create(name: "T Takur", change_request: cr)
Tester.create(name: "L Miripin", change_request: cr)
Tester.create(name: "B B", change_request: cr)
Tester.create(name: "Redi tam", change_request: cr)
Tester.create(name: "Giburan Sanchez", change_request: cr)
Tester.create(name: "Rinarudi Andurian", change_request: cr)
Tester.create(name: "M D R", change_request: cr)
Tester.create(name: "T S", change_request: cr)
Tester.create(name: "Michael M", change_request: cr)
Tester.create(name: "Pert Deb", change_request: cr)
Tester.create(name: "Azhari v d wick", change_request: cr)
Tester.create(name: "John China", change_request: cr)

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

cr = ChangeRequest.new(user: user[1], entity_source: 'midtrans')
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