class IncidentReportPostmortemTime < ActiveRecord::Migration
  def change
    add_column :incident_reports, :postmortem_time, :datetime
    add_column :incident_reports, :postmortem_docs, :string
  end
end
