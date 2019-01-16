class CsvParser
	def self.process_csv(data)
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

    @approvers = []
    data['approvers'] = data['approvers'].split(',')
    data['approvers'].each do |s|
      if User.where("name": s.strip)[0].nil?
        error = true
      else
        @approvers << User.where("name": s.strip)[0]
      end
    end

    @collaborators = []
    if data['collaborators'] != []
      data['collaborators'] = data['collaborators'].split(',')
      data['collaborators'].each do |s|
        unless User.where("name": s.strip)[0].nil?
          @collaborators << User.where("name": s.strip)[0]
        end
      end
    end

    data.delete('approvers')
    data.delete('collaborators')

    return {'data': data, 'approvers': @approvers, 'collaborators': @collaborators, 'error': error}
  end

  def self.convert(str)
    str = str.split(',')
    str.each do |s|
      s.strip!
      s.sub! " ","_"
    end
  end
end