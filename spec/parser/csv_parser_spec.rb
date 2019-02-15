require 'spec_helper'
require 'csv_parser.rb'

include ActionDispatch::TestProcess
describe CsvParser do
	let!(:user) {FactoryGirl.create(:user)}
	let!(:approver_ar) {FactoryGirl.create(:approver_ar, email:'patrick.star@midtrans.com')}

  describe 'process csv' do
    it "can upload validated data csv file" do
      @file = fixture_file_upload('files/valid.csv', 'text/csv')
      valid, invalid = CsvParser.process_csv(@file, user)
      expect(valid.count).to match (8)
    end
    
    it "can upload not validated data csv file" do
      @file = fixture_file_upload('files/invalid.csv', 'text/csv')
      valid, invalid = CsvParser.process_csv(@file, user)
      expect(invalid.count).to match (11)
    end 

    it "can upload both validated and non validated data csv file" do
      @file = fixture_file_upload('files/valid_invalid.csv', 'text/csv')
      valid, invalid = CsvParser.process_csv(@file, user)
      expect(valid.count).to match (2)
      expect(invalid.count).to match (2)
    end 
  end

end