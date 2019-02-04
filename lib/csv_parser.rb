class CsvParser
  def self.process_csv(file, current_user)
    valid = []
    invalid = []
    CSV.foreach(file.path,headers: true, col_sep: ",") do |row|
      @data = CsvParser.extract(row.to_h)
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
    data["start_date"] = ""
    data["end_date"] = ""

    if data["fingerprint"] != ""
      data["fingerprint"] = convert(data['fingerprint'])
      data["fingerprint"].each do |i|
      	if ["business_operations","business_area","it_operations","server_room","archive_room","engineering_area"].include?(i)
        	data["fingerprint_"+i] = "1"
        else
        	error = true
        end
      end
    end

    if data["other_access"] != ""
      data['other_access'] = convert(data['other_access'])
      data["other_access"].each do |i|
      	if ['internet_access','slack_access','admin_tools','vpn_access','github_gitlab','exit_interview','access_card','parking_cards','id_card',
      		'name_card','insurance_card','cash_advance','metabase','solutions_dashboard'].include?(i)
        	data[i] = "1"
        else
        	error = true
        end
      end
    end

    if data["request_type"] != ""
      unless ['create', 'delete', 'modify'].include?(data["request_type"].downcase)
        data["request_type"] = ""
        error = true
      end
    else
      error = true
    end

    if data["access_type"] != ""
      unless ['temporary', 'permanent'].include?(data["access_type"].downcase)
        data["access_type"] = ""
        error = true
      end
    else
      error = true
    end

    data['set_approvers'] = []
    data['approvers'] = data['approvers'].split(',')
    data['set_approvers'] = User.where(email: data['approvers']).map(&:id)
    error = true if data['approvers'].size != data['set_approvers'].size

    data['collaborators'] = data['collaborators'].split(',')
    data['collaborator_ids'] = User.where(email: data['collaborators']).map(&:id)
    error = true if data['collaborators'].size != data['collaborator_ids'].size

    data.delete('approvers')
    data.delete('collaborators')
    data.delete("fingerprint")
    data.delete("other_access")

    return {'data': data, 'error': error}
  end

  def self.convert(str)
    str = str.split(',')
    str.each do |s|
      s.strip!
      s.sub! " ","_"
    end
  end
end