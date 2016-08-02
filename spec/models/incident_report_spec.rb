require 'spec_helper'

describe IncidentReport do
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
		expect(incident_report).to have(1).errors_on(:service_impact)
	end
	it "is invalid without a problem details" do
		incident_report = FactoryGirl.build(:incident_report, problem_details: nil)
		expect(incident_report).to have(1).errors_on(:problem_details)
	end
	it "is invalid without a how detected" do
		incident_report = FactoryGirl.build(:incident_report, how_detected: nil)
		expect(incident_report).to have(1).errors_on(:how_detected)
	end
	it "is invalid without a occurence time" do
		incident_report = FactoryGirl.build(:incident_report, occurrence_time: nil)
		expect(incident_report).to have(1).errors_on(:occurrence_time)
	end
	it 'is invalid without a detection time' do
		incident_report = FactoryGirl.build(:incident_report, detection_time: nil)
		expect(incident_report).to have(2).errors_on(:detection_time)
	end
	it "is invalid without a recovery time" do
		incident_report = FactoryGirl.build(:incident_report, recovery_time: nil)
		expect(incident_report).to have(1).errors_on(:recovery_time)
	end
	it "is invalid without a loss related issue" do
		incident_report = FactoryGirl.build(:incident_report, loss_related: nil)
		expect(incident_report).to have(1).errors_on(:loss_related)
	end

	it "is invalid without a occurred reason" do
		incident_report = FactoryGirl.build(:incident_report, occurred_reason: nil)
		expect(incident_report).to have(1).errors_on(:occurred_reason)
	end
	it "is invalid without a overlooked reason" do
		incident_report = FactoryGirl.build(:incident_report, overlooked_reason: nil)
		expect(incident_report).to have(1).errors_on(:overlooked_reason)
	end
	it "is invalid without a recovery action" do
		incident_report = FactoryGirl.build(:incident_report, recovery_action: nil)
		expect(incident_report).to have(1).errors_on(:recovery_action)
	end
	it "is invalid without a prevent action" do
		incident_report = FactoryGirl.build(:incident_report, prevent_action: nil)
		expect(incident_report).to have(1).errors_on(:prevent_action)
	end
	it "is invalid without a measurer status" do
		incident_report = FactoryGirl.build(:incident_report, measurer_status: nil)
		expect(incident_report).to have(2).errors_on(:measurer_status)
	end
	it "is invalid without a source" do
		incident_report = FactoryGirl.build(:incident_report, source: nil)
		expect(incident_report).to have(2).errors_on(:source)
	end
	it "is invalid without a reccurence" do
		incident_report = FactoryGirl.build(:incident_report, recurrence_concern: nil)
		expect(incident_report).to have(2).errors_on(:recurrence_concern)
	end
	it "is invalid without a rank" do
		incident_report = FactoryGirl.build(:incident_report, rank: nil)
		expect(incident_report).to have(2).errors_on(:rank)
	end
	it "is invalid with concern of recurrence other than low medium high" do
		incident_report = FactoryGirl.build(:incident_report, recurrence_concern: 'very_high')
		expect(incident_report).to have(1).errors_on(:recurrence_concern)
	end
	it "is invalid with status measurer other than implemented or development" do
		incident_report = FactoryGirl.build(:incident_report, measurer_status: 'deprecated')
		expect(incident_report).to have(1).errors_on(:measurer_status)
	end
	it "is invalid with rank other than number" do
		incident_report = FactoryGirl.build(:incident_report, rank: 'one')
		expect(incident_report).to have(1).errors_on(:rank)
	end
	it "is invalid with rank other than number 1 to 5" do
		incident_report = FactoryGirl.build(:incident_report, rank: 6)
		expect(incident_report).to have(1).errors_on(:rank)
	end
	it "is invalid with occurence time other than date time "
	it "is invalid with detection time other than date time "
	it "is invalid with recovery time other than date time "
end
