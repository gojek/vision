require 'spec_helper'
require 'mentioner'

describe CsvItemParser do
	let!(:user) {FactoryGirl.create(:user)}
	let!(:approver_ar) {FactoryGirl.create(:approver_ar, email:'patrick.star@***REMOVED***')}
	let(:raw_data) {{"request_type"=>"Create",
									 "access_type"=>"Permanent",
									 "start_date"=>"",
									 "end_date"=>"",
									 "business_justification"=>"Lorem ipsum",
									 "collaborators"=>"patrick.star@***REMOVED***",
									 "approvers"=>"patrick.star@***REMOVED***",
									 "employee_name"=>"Budi",
									 "employee_position"=>"SE",
									 "employee_department"=>"Engineer",
									 "employee_email_address"=>"Budi@***REMOVED***",
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

		it 'test extract_access_type' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_access_type)
			expect(item.data["access_type"]).to match(/^(Permanent)|(Temporary)/)
		end

		it 'test extract_access_type temporary' do
			raw_data["access_type"]="Temporary"
			raw_data["start_date"]="2018-01-01"
			raw_data["end_date"]="2018-01-12"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_access_type)
			expect(item.data["access_type"]).to match(/^(Permanent)|(Temporary)/)
			expect(item.data["start_date"]).to eq(Date.parse(raw_data["start_date"]))
			expect(item.data["end_date"]).to eq(Date.parse(raw_data["end_date"]))
		end

		it 'test extract_request_type' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_request_type)
			expect(item.data["request_type"]).to match(/^(Create)|(Delete)|(Modify)/)
		end

		it 'test extract_approvers' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_approvers)
			expect(item.data).to have_key("set_approvers")
		end

		it 'test extract_collaborators' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_collaborators)
			expect(item.data).to have_key("collaborator_ids")
		end

		it 'test clear unused field' do
			item = CsvItemParser.new(raw_data, user)
			item.send(:clear_field)
			expect(item.data).not_to have_key("approvers")
			expect(item.data).not_to have_key("collaborators")
			expect(item.data).not_to have_key("fingerprint")
			expect(item.data).not_to have_key("other_access")
		end
	end

	describe 'testing extract method with invalid value' do
		it 'test extract_fingerprint' do
			raw_data["fingerprint"]="party area"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_fingerprint)
			expect(item.error).to be_truthy
		end

		it 'test extract_other_access' do
			raw_data["other_access"]="bathroom access"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_other_access)
			expect(item.error).to be_truthy
		end

		it 'test extract_access_type' do
			raw_data["access_type"] = "Never"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_access_type)
			expect(item.data["access_type"]).to be_empty
		end

		it 'test extract_request_type' do
			raw_data["request_type"] = "Destroy"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_request_type)
			expect(item.data["request_type"]).to be_empty
		end

		it 'test extract_approvers' do
			raw_data["approvers"] = "johndoe@***REMOVED***"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_approvers)
			expect(item.data["set_approvers"]).to be_empty
		end

		it 'test extract_collaborators' do
			raw_data["collaborators"] = "johndoe@***REMOVED***"
			item = CsvItemParser.new(raw_data, user)
			item.send(:extract_collaborators)
			expect(item.data["collaborator_ids"]).to be_empty
		end
	end

	describe 'testing data processing' do
		it 'is a valid access request' do
			item = CsvItemParser.new(raw_data, user).extract
			ar = item.generate_access_request
			expect(ar.valid? && !item.error).to eq(true)
		end

		it 'is a valid access request with minimum requirements' do
			raw_data["collaborators"] = ""
			raw_data["fingerprint"] = ""
			raw_data["corporate_email"] = ""
			raw_data["other_access"] = ""
			raw_data["password_reset"] = ""
			raw_data["user_identification"] = ""
			raw_data["asset_name"] = ""
			raw_data["production_asset"] = ""
			raw_data["production_access"] = ""
			raw_data["production_user_id"] = ""

			item = CsvItemParser.new(raw_data, user).extract
			ar = item.generate_access_request
			expect(ar.valid? && !item.error).to eq(true)
		end	

		it 'is an invalid access request' do
			raw_data["approvers"] = ""
			item = CsvItemParser.new(raw_data, user).extract
			ar = item.generate_access_request
			expect(ar.valid? && !item.error).to eq(false)
		end
	end
end