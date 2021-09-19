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
user_requester = User.find_or_create_by(email: "17@veritrans.co.id", role: "requestor", name: "Seorang Requestor")
user_approver = User.find_or_create_by(email: "18@veritrans.co.id", role: "approver", name: "Seorang Approver")


user_requesters = []
(1..20).each do |i|
  user_requesters[i] = User.new(email: "email#{i}@veritrans.co.id", role: "requestor")
end

user_requesters[1].name = "Nayana Tara Reng Kyu"
user_requesters[2].name = "Rinarudi Andurian"
user_requesters[3].name = "Giburan Sanchez"
user_requesters[4].name = "Azhari von Der Wick"
user_requesters[5].name = "John China"
user_requesters[6].name = "Reddit Tamasya"
user_requesters[7].name = "Pingu Pingi"
user_requesters[8].name = "Lahan Peqerjaan"
user_requesters[9].name = "Pertalite Debest"
user_requesters[10].name = "Michael Mikaelah"
user_requesters[11].name = "Bruce Bigotry"
user_requesters[12].name = "Lahma Miripin"
user_requesters[13].name = "Random Name"
user_requesters[14].name = "Slayer bin Ibnu Abbas"
user_requesters[15].name = "Riomu Liario"
user_requesters[16].name = "Lutfi Kp Lagi Cuy"
user_requesters[17].name = "Mang Apark"
user_requesters[18].name = "Mang Afox"
user_requesters[19].name = "Mang Awan"
user_requesters[20].name = "Tuhan Takur"

(1..20).each do |i|
  user_requesters[i].save
end

change_request = ChangeRequest.new(user: user_requester, entity_source: 'midtrans', change_summary: 'Change Summary 1')
change_request.save(validate: false)

Tester.create(name: "Mohamad Dwiyan Rahmanianto", change_request: change_request)
Tester.create(name: "Nayana Tara", change_request: change_request)
Tester.create(name: "Ya Leus", change_request: change_request)
Tester.create(name: "Thisis AsEed", change_request: change_request)
Tester.create(name: "Lahan P", change_request: change_request)
Tester.create(name: "L K L C", change_request: change_request)
Tester.create(name: "M Apark", change_request: change_request)
Tester.create(name: "Mang Af0x", change_request: change_request)
Tester.create(name: "M ang Aw an", change_request: change_request)
Tester.create(name: "T Takur", change_request: change_request)
Tester.create(name: "L Miripin", change_request: change_request)
Tester.create(name: "B B", change_request: change_request)
Tester.create(name: "Redi tam", change_request: change_request)
Tester.create(name: "Giburan Sanchez", change_request: change_request)
Tester.create(name: "Rinarudi Andurian", change_request: change_request)
Tester.create(name: "M D R", change_request: change_request)
Tester.create(name: "T S", change_request: change_request)
Tester.create(name: "Michael M", change_request: change_request)
Tester.create(name: "Pert Deb", change_request: change_request)
Tester.create(name: "Azhari v d wick", change_request: change_request)
Tester.create(name: "John China", change_request: change_request)



user_approvers = []
(1..15).each do |i|
  user_approvers[i] = User.new(email: "email.user#{i}@veritrans.co.id", role: "approver")
end
user_approvers[1].name = "Tatang Seekor Nyamuk"
user_approvers[2].name = "Budi Santoso"
user_approvers[3].name = "Karla Lulu Lava"
user_approvers[4].name = "Lala Lulu Lovo"
user_approvers[5].name = "Saya Lapar Log"
user_approvers[6].name = "Sudirman Duniarjo"
user_approvers[7].name = "John Van Bejo"
user_approvers[8].name = "Julaeha Princess"
user_approvers[9].name = "Maman Sukaman Temanteman"
user_approvers[10].name = "Jack Hogan"
user_approvers[11].name = "James Bond"
user_approvers[12].name = "Peter Parker"
user_approvers[13].name = "Robert Dawney"
user_approvers[14].name = "Harry Potter"
user_approvers[15].name = "Aragorn Arathorn"

(1..15).each do |i|
  user_approvers[i].save
end

change_request_with_approval = ChangeRequest.new(user: user_requester, entity_source: 'midtrans', change_summary: 'Change Summary 2')
change_request_with_approval.save(validate: false)

Approval.create(user: user_approver, change_request: change_request_with_approval)

Implementer.create(name: "Tatang Nyamuk", change_request: change_request_with_approval)
Implementer.create(name: "Budi Santoso", change_request: change_request_with_approval)
Implementer.create(name: "Lulu L", change_request: change_request_with_approval)
Implementer.create(name: "Saya Lapar", change_request: change_request_with_approval)
Implementer.create(name: "S Duniarjo", change_request: change_request_with_approval)
Implementer.create(name: "John B", change_request: change_request_with_approval)
Implementer.create(name: "Princess", change_request: change_request_with_approval)
Implementer.create(name: "Sukaman", change_request: change_request_with_approval)
Implementer.create(name: "Jack H", change_request: change_request_with_approval)
Implementer.create(name: "Peter Parker", change_request: change_request_with_approval)
Implementer.create(name: "James B", change_request: change_request_with_approval)
Implementer.create(name: "Peter P", change_request: change_request_with_approval)
Implementer.create(name: "R Dawney", change_request: change_request_with_approval)
Implementer.create(name: "Harry Poter", change_request: change_request_with_approval)
Implementer.create(name: "Aragorn Arathorn Anton", change_request: change_request_with_approval)

change_request_version = change_request.versions.last
change_request_version.whodunnit = user_requester.id
change_request_version.save

change_request_with_approval_version = change_request_with_approval.versions.last
change_request_with_approval_version.whodunnit = user_requester.id
change_request_with_approval_version.save