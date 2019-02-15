class CsvItemParser
	ALLOWED_FIELD = ["request_type","access_type","start_date","end_date","business_justification",
		"collaborators","approvers","employee_name","employee_position","employee_department",
		"employee_email_address","employee_phone","employee_access","fingerprint","corporate_email",
		"other_access","password_reset","user_identification","asset_name","production_access",
		"production_user_id","production_asset"]
	FINGERPRINT_CONST = ["business_operations","business_area","it_operations","server_room","archive_room","engineering_area"]
  OTHER_ACCESS_CONST = ['internet_access','slack_access','admin_tools','vpn_access','github_gitlab',
  	'exit_interview','access_card','parking_cards','id_card',
  	'name_card','insurance_card','cash_advance','metabase','solutions_dashboard']

  attr_reader :data, :error, :user

	def self.parse(data, current_user)
		item = CsvItemParser.new(data, current_user).extract
	end

	def initialize(raw_data, current_user)
    @data = fetch_allowed_field_from(raw_data)
    @error = false
    @user = current_user
  end

	def extract
		extract_fingerprint
		extract_other_access
		extract_request_type
		extract_access_type
		extract_approvers
		extract_collaborators
		clear_field
		return self
	end

	def generate_access_request
		@user.AccessRequests.build(@data)
	end

	def item_valid?
		@error
	end

  private
	def extract_fingerprint
    if @data["fingerprint"].present?
      items = parse(@data["fingerprint"])
      if validate(items, FINGERPRINT_CONST)
        @error = true
      else
        items.map { |item| @data["fingerprint_#{item}"] = 1 }
      end
    end
  end

  def extract_other_access
  	if @data["other_access"].present?
      items = parse(@data["other_access"])
      if validate(items, OTHER_ACCESS_CONST)
        @error = true
      else
        items.map { |item| @data[item] = 1 }
      end
    end
  end

  def extract_request_type
		if @data["request_type"].empty? || ['Create', 'Delete', 'Modify'].exclude?(@data["request_type"].capitalize)
      @data["request_type"] = ""
      @error = true
    else
      @data["request_type"].capitalize!
    end
  end

  def extract_access_type
  	if @data["access_type"].empty? || ['Temporary', 'Permanent'].exclude?(@data["access_type"].capitalize)
      @data["access_type"] = ""
      @error = true
    else
      @data["access_type"].capitalize!
    end

    if @data["access_type"] == 'Temporary'
      if @data["start_date"].empty? && @data["end_date"].empty?
        @error = true
      else
        begin
          @data["start_date"] = Date.parse(@data["start_date"])
          @data["end_date"] = Date.parse(@data["end_date"])
        rescue
          @error = true
        end
      end
    end
  end

  def extract_approvers
  	@data['approvers'] = @data['approvers'].split(',')
    @data['set_approvers'] = User.where(email: @data['approvers'].map{|email| email.strip }).map(&:id)
    @error = true if @data['approvers'].size != @data['set_approvers'].size
  end

  def extract_collaborators
  	@data['collaborators'] = @data['collaborators'].split(',')
    @data['collaborator_ids'] = User.where(email: @data['collaborators'].map{|email| email.strip }).map(&:id)
    @error = true if @data['collaborators'].size != @data['collaborator_ids'].size
  end

  def clear_field
  	@data.delete('approvers')
    @data.delete('collaborators')
    @data.delete("fingerprint")
    @data.delete("other_access")
  end

  def fetch_allowed_field_from(raw_data)
    ALLOWED_FIELD.map { |field| [field, raw_data[field]] }.to_h
  end

  def parse(column)
    column.split(',').map {|s| s.strip.sub " ","_" }
  end

  def validate(items, available_items)
    (items - available_items).present?
  end
end