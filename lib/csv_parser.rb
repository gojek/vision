class CsvParser
  def self.process_csv(file, current_user)
    valid = []
    invalid = []
    CSV.foreach(file.path,headers: true, col_sep: ",") do |row|
      @data = CsvParser.extract(row.to_h)
      @access_request = current_user.AccessRequests.build(@data[:data])
      if (@data[:error])
        invalid << @access_request
      else
        if @access_request.valid?
          valid << @access_request
        else
          invalid << @access_request
        end
      end
    end
    return valid, invalid
  end

  def self.extract(data)
    error = false
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
    data.delete("fingerprint")

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
    data.delete("other_access")

    data["start_date"] = ""
    data["end_date"] = ""

    data['set_approvers'] = []
    data['approvers'] = data['approvers'].split(',')
    list_approver = User.where(email: data['approvers'])
    list_approver.each do |s|
      data['set_approvers'] << s.id
    end
    error = true if data['approvers'].size != data['set_approvers'].size
      
    data['collaborator_ids'] = []
    if data['collaborators'] != []
      data['collaborators'] = data['collaborators'].split(',')
      list_collaborators = User.where(email: data['collaborators'])
      list_collaborators.each do |s|
        data['collaborator_ids'] << s.id
      end
      error = true if data['collaborators'].size != data['collaborator_ids'].size
    end

    data.delete('approvers')
    data.delete('collaborators')

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