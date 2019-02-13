class CsvParser
  FINGERPRINT_CONST = ["business_operations","business_area","it_operations","server_room","archive_room","engineering_area"]
  OTHER_ACCESS_CONST = ['internet_access','slack_access','admin_tools','vpn_access','github_gitlab','exit_interview','access_card','parking_cards','id_card',
          'name_card','insurance_card','cash_advance','metabase','solutions_dashboard']
  def self.process_csv(file, current_user)
    valid = []
    invalid = []
    CSV.foreach(file.path,headers: true, col_sep: ",") do |row|
      @data = extract(row.to_h)
      @access_request = current_user.AccessRequests.build(@data[:data])
      if @data[:error] || @access_request.invalid?
        invalid << @access_request
      else
        valid << @access_request
      end
    end
    return valid, invalid
  end

  def self.extract(data)
    error = false

    if !data["fingerprint"].empty?
      items = parse(data["fingerprint"])
      if validate(items, FINGERPRINT_CONST)
        error = true
      else
        items.map { |item| data["fingerprint_#{item}"] = 1 }
      end
    end

    if !data["other_access"].empty?
      items = parse(data["other_access"])
      if validate(items, OTHER_ACCESS_CONST)
        error = true
      else
        items.map { |item| data[item] = 1 }
      end
    end

    if data["request_type"].empty? || ['Create', 'Delete', 'Modify'].exclude?(data["request_type"].capitalize)
      data["request_type"] = ""
      error = true
    else
      data["request_type"].capitalize!
    end

    if data["access_type"].empty? || ['Temporary', 'Permanent'].exclude?(data["access_type"].capitalize)
      data["access_type"] = ""
      error = true
    else
      data["access_type"].capitalize!
    end

    if data["access_type"] == 'Temporary'
      if data["start_date"].empty? && data["end_date"].empty?
        error = true
      else
        begin
          data["start_date"] = Date.parse(data["start_date"])
          data["end_date"] = Date.parse(data["end_date"])
        rescue
          error = true
        end
      end
    end

    data['approvers'] = data['approvers'].split(',')
    data['set_approvers'] = User.where(email: data['approvers'].map{|email| email.strip }).map(&:id)
    error = true if data['approvers'].size != data['set_approvers'].size

    data['collaborators'] = data['collaborators'].split(',')
    data['collaborator_ids'] = User.where(email: data['collaborators'].map{|email| email.strip }).map(&:id)
    error = true if data['collaborators'].size != data['collaborator_ids'].size

    data.delete('approvers')
    data.delete('collaborators')
    data.delete("fingerprint")
    data.delete("other_access")

    return {'data': data, 'error': error}
  end

  private
  def self.parse(column)
    column.split(',').map {|s| s.strip.sub " ","_" }
  end

  def self.validate(items, available_items)
    (items - available_items).present?
  end
end