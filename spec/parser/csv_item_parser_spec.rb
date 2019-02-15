require 'spec_helper'
require 'mentioner'

describe CsvItemParser do
	let!(:user) {FactoryGirl.create(:user)}
	let!(:approver_ar) {FactoryGirl.create(:approver_ar, email:'patrick.star@midtrans.com')}
	let(:raw_data) {{"request_type"=>"Create",
									 "access_type"=>"Permanent",
									 "start_date"=>"",
									 "end_date"=>"",
									 "business_justification"=>"Lorem ipsum",
									 "collaborators"=>"patrick.star@midtrans.com",
									 "approvers"=>"patrick.star@midtrans.com",
									 "employee_name"=>"Budi",
									 "employee_position"=>"SE",
									 "employee_department"=>"Engineer",
									 "employee_email_address"=>"Budi@midtrans.com",
									 "employee_phone"=>"14045",
									 "employee_access"=>"1",
									 "fingerprint"=>"business area,business operations",
									 "corporate_email"=>"-",
									 "other_access"=>"internet access, slack access, vpn access",
									 "password_reset"=>"1",
									 "user_identification"=>"gatau ini apa",
									 "asset_name"=>"apa lagi ini",
									 "production_access"=>"1",
									 "production_user_id"=>"Ini apa pula",
									 "production_asset"=>"apa ini yaampun"}}

	

	describe 'testing extract method' do
		it 'test extract_fingerprint' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_fingerprint)
			expect(item.data).to have_key("fingerprint_business_area")
			expect(item.data).to have_key("fingerprint_business_operations")
		end

		it 'test extract_other_access' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_other_access)
			expect(item.data).to have_key("internet_access")
			expect(item.data).to have_key("slack_access")
			expect(item.data).to have_key("vpn_access")
		end
	end
end