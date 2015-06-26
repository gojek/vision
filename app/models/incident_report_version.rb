# model for paper_trail IncidentReport version
class IncidentReportVersion < PaperTrail::Version
  self.table_name = :incident_report_versions
  default_scope { where.not(event: 'create') }
end
