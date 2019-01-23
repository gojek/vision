require 'spec_helper'

describe AccessRequestsController, type: :controller do
  context 'user access' do
    let(:user) {FactoryGirl.create(:user)}
    let(:approver_ar) {FactoryGirl.create(:approver_ar)}
    let(:access_request) {access_request = FactoryGirl.create(:access_request, user: user)}
    let(:file_path) { "spec/fixtures/files/wa.csv" }
   
    before :each do
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    after :each do
      File.delete(file_path)
    end

    describe 'POST #import_from_csv' do
      it "can upload a csv" do
        CSV.open(file_path, "w") do |c|
          c << ["request_type","access_type","business_justification","collaborators","approvers","employee_name","employee_position","employee_department","employee_email_address","employee_phone","employee_access","fingerprint","corporate_email","other_access","password_reset","user_identification","asset_name","production_access","production_user_id","production_asset"] #hash keys
          c << ["Create","Permanent","Lorem ipsum","Siapa ya","patrick star","Budi","SE","Engineer","Budi@midtrans.com","14045","1","business area,business operations,it operations,server room,archive room,engineering area","-","internet access, slack access, vpn access","1","gatau ini apa","apa lagi ini","1","Ini apa pula","apa ini yaampun"]
          c << ["Create","Permanent","Lorem ipsum","patrick star","spongebob","Budi","SE","Engineer","Budi@midtrans.com","14045","1","business area,business operations,it operations,server room,archive room,engineering area","-","internet access, slack access, vpn access","1","gatau ini apa","apa lagi ini","1","Ini apa pula","apa ini yaampun"]
        end
        @file = fixture_file_upload('files/wa.csv', 'text/csv')
        post :import_from_csv, :csv => @file
        expect(response).to redirect_to access_requests_path
      end

      it "can upload a csv and successfuly create an access_request" do
        CSV.open(file_path, "w") do |c|
          c << ["request_type","access_type","business_justification","collaborators","approvers","employee_name","employee_position","employee_department","employee_email_address","employee_phone","employee_access","fingerprint","corporate_email","other_access","password_reset","user_identification","asset_name","production_access","production_user_id","production_asset"] #hash keys
          c << ["Create","Permanent","Lorem ipsum","Siapa ya","patrick star","Budi","SE","Engineer","Budi@midtrans.com","14045","1","business area,business operations,it operations,server room,archive room,engineering area","-","internet access, slack access, vpn access","1","gatau ini apa","apa lagi ini","1","Ini apa pula","apa ini yaampun"]
        end
        @file = fixture_file_upload('files/wa.csv', 'text/csv')
        post :import_from_csv, :csv => @file
        expect(flash[:notice]).to match "1 Access request(s) was successfully created."
      end

      context 'unsuccessfuly submit csv' do
        it "can upload an invalid csv (user error)" do
          CSV.open(file_path, "w") do |c|
            c << ["request_type","access_type","business_justification","collaborators","approvers","employee_name","employee_position","employee_department","employee_email_address","employee_phone","employee_access","fingerprint","corporate_email","other_access","password_reset","user_identification","asset_name","production_access","production_user_id","production_asset"] #hash keys
            c << ["Create","Permanent","Lorem ipsum","Siapa ya","squidward","Budi","SE","Engineer","Budi@midtrans.com","14045","1","business area,business operations,it operations,server room,archive room,engineering area","-","internet access, slack access, vpn access","1","gatau ini apa","apa lagi ini","1","Ini apa pula","apa ini yaampun"]
          end
          @file = fixture_file_upload('files/wa.csv', 'text/csv')
          post :import_from_csv, :csv => @file
          expect(flash[:invalid]).to match "1 data(s) is not filled correctly, the data was saved as a draft"
        end

        it "can upload an invalid csv (employee access error)" do
          CSV.open(file_path, "w") do |c|
            c << ["request_type","access_type","business_justification","collaborators","approvers","employee_name","employee_position","employee_department","employee_email_address","employee_phone","employee_access","fingerprint","corporate_email","other_access","password_reset","user_identification","asset_name","production_access","production_user_id","production_asset"] #hash keys
            c << ["Create","Permanent","Lorem ipsum","Siapa ya","patrick star","Budi","SE","Engineer","Budi@midtrans.com","14045","1","party area","-","internet access, slack access, vpn access","1","gatau ini apa","apa lagi ini","1","Ini apa pula","apa ini yaampun"]
          end
          @file = fixture_file_upload('files/wa.csv', 'text/csv')
          post :import_from_csv, :csv => @file
          expect(flash[:invalid]).to match "1 data(s) is not filled correctly, the data was saved as a draft"
        end

        it "can upload an invalid csv (other access error)" do
          CSV.open(file_path, "w") do |c|
            c << ["request_type","access_type","business_justification","collaborators","approvers","employee_name","employee_position","employee_department","employee_email_address","employee_phone","employee_access","fingerprint","corporate_email","other_access","password_reset","user_identification","asset_name","production_access","production_user_id","production_asset"] #hash keys
            c << ["Create","Permanent","Lorem ipsum","Siapa ya","patrick star","Budi","SE","Engineer","Budi@midtrans.com","14045","1","business area","-","bathroom access","1","gatau ini apa","apa lagi ini","1","Ini apa pula","apa ini yaampun"]
          end
          @file = fixture_file_upload('files/wa.csv', 'text/csv')
          post :import_from_csv, :csv => @file
          expect(flash[:invalid]).to match "1 data(s) is not filled correctly, the data was saved as a draft"
        end
      end
    end

  end
end
