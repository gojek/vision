# frozen_string_literal: true

class CSVExporter
  def self.export_from_active_records(records)
    Enumerator.new do |lines|
      lines << records.model.to_comma_headers.to_csv
      records.find_each do |record|
        lines << record.to_comma.to_csv
      end
    end
  end
end