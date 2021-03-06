# frozen_string_literal: true

require 'access_request_csv_parser'

class AccessRequestsCsvParser
  def self.process_csv(file, current_user)
    @valid = []
    @invalid = []
    CSV.foreach(file.path, headers: true, col_sep: ',') do |row|
      item_parser = AccessRequestCsvParser.parse(row.to_h, current_user)
      if item_parser.item_invalid?
        @invalid << item_parser.access_request
      else
        @valid << item_parser.access_request
      end
    end
    [@valid, @invalid]
  end
end
