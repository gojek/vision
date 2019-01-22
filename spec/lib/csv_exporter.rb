require 'spec_helper'
require 'csv_exporter'

describe CSVExporter do
  
  before :each do
    FactoryGirl.create(:access_request, employee_name: 'Employee 1')
    FactoryGirl.create(:access_request, employee_name: 'Employee 2')
  end

  it 'should return valid csv' do
    access_requests = AccessRequest.all
    enumerator = CSVExporter.export_from_active_records(access_requests)
    expect(enumerator.next).to eq(AccessRequest.to_comma_headers.to_csv)
    expect(enumerator.next).to eq(AccessRequest.first.to_comma.to_csv)
    expect(enumerator.next).to eq(AccessRequest.last.to_comma.to_csv) 
    expect(enumerator.class.to_s).to eq('Enumerator')
  end
end