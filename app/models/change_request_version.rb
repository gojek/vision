class ChangeRequestVersion < PaperTrail::Version
  self.table_name = :change_request_versions
  default_scope { where.not(event: 'create') } 
end