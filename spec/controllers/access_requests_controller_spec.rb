require 'spec_helper'

describe AccessRequestsController, type: :controller do
  context 'user access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:approver_ar) {FactoryGirl.create(:approver_ar)}
    let(:access_request) {access_request = FactoryGirl.create(:access_request, user: user)}
   
    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'POST #import_from_csv' do
      it "can upload validated data csv file" do
        @file = fixture_file_upload('files/valid.csv', 'text/csv')
        post :import_from_csv, :csv => @file
        expect(flash[:notice]).to match "3 Access request(s) was successfully created."
      end
      
      it "can upload not validated data csv file" do
        @file = fixture_file_upload('files/invalid.csv', 'text/csv')
        post :import_from_csv, :csv => @file
        expect(flash[:invalid]).to match "8 data(s) is not filled correctly, the data was saved as a draft"
      end 

      it "can upload both validated and non validated data csv file" do
        @file = fixture_file_upload('files/valid_invalid.csv', 'text/csv')
        post :import_from_csv, :csv => @file
        expect(flash[:notice]).to match "2 Access request(s) was successfully created."
        expect(flash[:invalid]).to match "2 data(s) is not filled correctly, the data was saved as a draft"
      end 
    end

  end
end
