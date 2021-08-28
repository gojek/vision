require 'rails_helper'
require 'mentioner'

describe AccessRequestCsvParser do
  let!(:user) {FactoryGirl.create(:user)}
  let!(:approver_ar) {FactoryGirl.create(:approver_ar, email:'patrick.star@midtrans.com')}
  let(:raw_data) {{"entity_source"=>"midtrans",
                   "request_type"=>"Create",
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
    it 'test extract_entity' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_entity)
      expect(item_parser.data).to have_key("entity_source")
      expect(item_parser.data['entity_source']).to eq("Midtrans")
    end

    it 'test extract_fingerprint' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_fingerprint)
      expect(item_parser.data).to have_key("fingerprint_business_area")
      expect(item_parser.data).to have_key("fingerprint_business_operations")
    end

    it 'test extract_other_access' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_other_access)
      expect(item_parser.data).to have_key("internet_access")
      expect(item_parser.data).to have_key("slack_access")
      expect(item_parser.data).to have_key("vpn_access")
    end

    it 'test extract_access_type' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_access_type)
      expect(item_parser.data["access_type"]).to match(/^(Permanent)|(Temporary)/)
    end

    it 'test extract_access_type temporary' do
      raw_data["access_type"]="Temporary"
      raw_data["start_date"]="2018-01-01"
      raw_data["end_date"]="2018-01-12"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_access_type)
      expect(item_parser.data["access_type"]).to match(/^(Permanent)|(Temporary)/)
      expect(item_parser.data["start_date"]).to eq(Date.parse(raw_data["start_date"]))
      expect(item_parser.data["end_date"]).to eq(Date.parse(raw_data["end_date"]))
    end

    it 'test extract_request_type' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_request_type)
      expect(item_parser.data["request_type"]).to match(/^(Create)|(Delete)|(Modify)/)
    end

    it 'test extract_approvers' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_approvers)
      expect(item_parser.data).to have_key("approver_ids")
    end

    it 'test extract_collaborators' do
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_collaborators)
      expect(item_parser.data).to have_key("collaborator_ids")
    end
  end

  describe 'testing extract method with invalid value' do
    it 'test extract_fingerprint' do
      raw_data["fingerprint"]="party area"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_fingerprint)
      expect(item_parser.error).to be_truthy
    end

    it 'test extract_other_access' do
      raw_data["other_access"]="bathroom access"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_other_access)
      expect(item_parser.error).to be_truthy
    end

    it 'test extract_access_type' do
      raw_data["access_type"] = "Never"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_access_type)
      expect(item_parser.data["access_type"]).to be_empty
    end

    it 'test extract_request_type' do
      raw_data["request_type"] = "Destroy"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_request_type)
      expect(item_parser.data["request_type"]).to be_empty
    end

    it 'test extract_approvers' do
      raw_data["approvers"] = "johndoe@midtrans.com"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_approvers)
      expect(item_parser.data["approver_ids"]).to be_empty
    end

    it 'test extract_collaborators' do
      raw_data["collaborators"] = "johndoe@midtrans.com"
      item_parser = AccessRequestCsvParser.new(raw_data, user)
      item_parser.send(:extract_collaborators)
      expect(item_parser.data["collaborator_ids"]).to be_empty
    end
  end

  describe 'testing data processing' do
    it 'is a valid access request' do
      item_parser = AccessRequestCsvParser.new(raw_data, user).extract
      expect(item_parser.item_invalid?).to eq(false)
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

      item_parser = AccessRequestCsvParser.new(raw_data, user).extract
      expect(item_parser.item_invalid?).to eq(false)
    end 

    it 'is an invalid access request' do
      raw_data["approvers"] = ""
      item_parser = AccessRequestCsvParser.new(raw_data, user).extract
      expect(item_parser.item_invalid?).to eq(true)
    end
  end
end
