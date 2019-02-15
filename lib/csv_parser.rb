require 'csv_item_parser.rb'

class CsvParser
  def self.process_csv(file, current_user)
    valid = []
    invalid = []
    CSV.foreach(file.path,headers: true, col_sep: ",") do |row|
      item_parser = CsvItemParser.parse(row.to_h, current_user)
      ar = item_parser.generate_access_request
      if ar.invalid? || item_parser.item_valid?
        invalid << ar
      else
        valid << ar
      end
    end
    return valid, invalid
  end
end