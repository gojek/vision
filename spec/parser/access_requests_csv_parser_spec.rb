require 'rails_helper'
require 'access_requests_csv_parser.rb'

include ActionDispatch::TestProcess
describe AccessRequestsCsvParser do
	let!(:user) {FactoryBot.create(:user)}
	let!(:approver_ar) {FactoryBot.create(:approver_ar, email:'patrick.star@gmail.com')}

  describe 'process csv' do
    it "can upload validated data csv file" do
      @file = fixture_file_upload('files/valid.csv', 'text/csv')
      valid, invalid = AccessRequestsCsvParser.process_csv(@file, user)
      expect(valid.count).to match (9)
      expect(invalid.count).to match (0)
    end
    
    it "can upload not validated data csv file" do
      @file = fixture_file_upload('files/invalid.csv', 'text/csv')
      valid, invalid = AccessRequestsCsvParser.process_csv(@file, user)
      expect(invalid.count).to match (12)
      expect(valid.count).to match (0)
    end 

    it "can upload both validated and non validated data csv file" do
      @file = fixture_file_upload('files/valid_invalid.csv', 'text/csv')
      valid, invalid = AccessRequestsCsvParser.process_csv(@file, user)
      expect(valid.count).to match (2)
      expect(invalid.count).to match (2)
    end 
  end

end