require 'spec_helper'

describe IncidentReport do

	#shoulda matchers test
	it { should belong_to(:user)}
	it { should have_many(:notifications).dependent(:destroy) }
	
	it "is valid with all attibute filled" do
		expect(FactoryGirl.build(:incident_report)).to be_valid
	end
	it "is valid with rank number 1- 5"
	it "is valid with current status either recovered or on going"
	it "is valid with source either external or internal"
	it "is valid with concern of reccurence one these option low medium or high"
	it "is valid with status of measurer either implemeted or development"
	it "is invalid without a service impact" do
		incident_report = FactoryGirl.build(:incident_report, service_impact: nil)
		incident_report.valid?
		expect(incident_report.errors[:service_impact].size).to eq(1)
	end
	it "is invalid without a problem details" do
		incident_report = FactoryGirl.build(:incident_report, problem_details: nil)
		incident_report.valid?
		expect(incident_report.errors[:problem_details].size).to eq(1)
	end
	it "is invalid without a how detected" do
		incident_report = FactoryGirl.build(:incident_report, how_detected: nil)
		incident_report.valid?
		expect(incident_report.errors[:how_detected].size).to eq(1)
	end
	it "is invalid without a occurence time" do
		incident_report = FactoryGirl.build(:incident_report, occurrence_time: nil)
		incident_report.valid?
		expect(incident_report.errors[:occurrence_time].size).to eq(1)
	end
	it 'is invalid without a detection time' do
		incident_report = FactoryGirl.build(:incident_report, detection_time: nil)
		incident_report.valid?
		expect(incident_report.errors[:detection_time].size).to eq(2)
	end
	it "is invalid without a recovery time" do
		incident_report = FactoryGirl.build(:incident_report, recovery_time: nil)
		incident_report.valid?
		expect(incident_report.errors[:recovery_time].size).to eq(1)
	end
	it "is invalid without a loss related issue" do
		incident_report = FactoryGirl.build(:incident_report, loss_related: nil)
		incident_report.valid?
		expect(incident_report.errors[:loss_related].size).to eq(1)
	end

	it "is invalid without a occurred reason" do
		incident_report = FactoryGirl.build(:incident_report, occurred_reason: nil)
		incident_report.valid?
		expect(incident_report.errors[:occurred_reason].size).to eq(1)
	end
	it "is invalid without a overlooked reason" do
		incident_report = FactoryGirl.build(:incident_report, overlooked_reason: nil)
		incident_report.valid?
		expect(incident_report.errors[:overlooked_reason].size).to eq(1)
	end
	it "is invalid without a recovery action" do
		incident_report = FactoryGirl.build(:incident_report, recovery_action: nil)
		incident_report.valid?
		expect(incident_report.errors[:recovery_action].size).to eq(1)
	end
	it "is invalid without a prevent action" do
		incident_report = FactoryGirl.build(:incident_report, prevent_action: nil)
		incident_report.valid?
		expect(incident_report.errors[:prevent_action].size).to eq(1)
	end
	it "is invalid without a measurer status" do
		incident_report = FactoryGirl.build(:incident_report, measurer_status: nil)
		incident_report.valid?
		expect(incident_report.errors[:measurer_status].size).to eq(2)
	end
	it "is invalid without a source" do
		incident_report = FactoryGirl.build(:incident_report, source: nil)
		incident_report.valid?
		expect(incident_report.errors[:source].size).to eq(2)
	end
	it "is invalid without a reccurence" do
		incident_report = FactoryGirl.build(:incident_report, recurrence_concern: nil)
		incident_report.valid?
		expect(incident_report.errors[:recurrence_concern].size).to eq(2)
	end
	it "is invalid without a rank" do
		incident_report = FactoryGirl.build(:incident_report, rank: nil)
		incident_report.valid?
		expect(incident_report.errors[:rank].size).to eq(2)
	end
	it "is invalid with concern of recurrence other than low medium high" do
		incident_report = FactoryGirl.build(:incident_report, recurrence_concern: 'very_high')
		incident_report.valid?
		expect(incident_report.errors[:recurrence_concern].size).to eq(1)
	end
	it "is invalid with status measurer other than implemented or development" do
		incident_report = FactoryGirl.build(:incident_report, measurer_status: 'deprecated')
		incident_report.valid?
		expect(incident_report.errors[:measurer_status].size).to eq(1)
	end
	it "is invalid with rank other than number" do
		incident_report = FactoryGirl.build(:incident_report, rank: 'one')
		incident_report.valid?
		expect(incident_report.errors[:rank].size).to eq(1)
	end
	it "is invalid with rank other than number 1 to 5" do
		incident_report = FactoryGirl.build(:incident_report, rank: 6)
		incident_report.valid?
		expect(incident_report.errors[:rank].size).to eq(1)
	end
	it "is invalid with occurence time other than date time "
	it "is invalid with detection time other than date time "
	it "is invalid with recovery time other than date time "
end
