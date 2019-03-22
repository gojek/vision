# frozen_string_literal: true

class AccessRequestCsvParser
  ALLOWED_FIELD = %w[business_justification employee_name employee_position employee_department
                     employee_email_address employee_phone employee_access corporate_email
                     password_reset user_identification asset_name production_access
                     production_user_id production_asset].freeze
  FINGERPRINT_CONST = %w[business_operations business_area it_operations
                         server_room archive_room engineering_area].freeze
  OTHER_ACCESS_CONST = %w[internet_access slack_access admin_tools vpn_access github_gitlab
                          exit_interview access_card parking_cards id_card
                          name_card insurance_card cash_advance metabase solutions_dashboard].freeze

  attr_reader :data, :error, :user

  def self.parse(data, current_user)
    AccessRequestCsvParser.new(data, current_user).extract
  end

  def initialize(raw_data, current_user)
    @raw_data = raw_data
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
    self
  end

  def access_request
    @access_request ||= @user.AccessRequests.build(@data)
  end

  def item_invalid?
    access_request.invalid? || @error
  end

  private

  def extract_fingerprint
    return if @raw_data['fingerprint'].blank?
    items = parse(@raw_data['fingerprint'])
    @error ||= !subset_of(items, FINGERPRINT_CONST)
    (items & FINGERPRINT_CONST).map { |item| @data["fingerprint_#{item}"] = 1 }
  end

  def extract_other_access
    return if @raw_data['other_access'].blank?
    items = parse(@raw_data['other_access'])
    @error ||= !subset_of(items, OTHER_ACCESS_CONST)
    (items & OTHER_ACCESS_CONST).map { |item| @data[item] = 1 }
  end

  def extract_request_type
    if @raw_data['request_type'].empty? || %w[Create Delete Modify].exclude?(@raw_data['request_type'].capitalize)
      @data['request_type'] = ''
      @error = true
    else
      @data['request_type'] = @raw_data['request_type'].capitalize
    end
  end

  def extract_access_type
    if @raw_data['access_type'].empty? || %w[Temporary Permanent].exclude?(@raw_data['access_type'].capitalize)
      @data['access_type'] = ''
      @error = true
    else
      @data['access_type'] = @raw_data['access_type'].capitalize
    end

    return if @data['access_type'] != 'Temporary'
    if @raw_data['start_date'].empty? || @raw_data['end_date'].empty?
      @error = true
    else
      begin
        @data['start_date'] = Date.parse(@raw_data['start_date'])
        @data['end_date'] = Date.parse(@raw_data['end_date'])
      rescue StandardError
        @data['access_type'] = ''
        @data['start_date'] = ''
        @data['end_date'] = ''
        @error = true
      end
    end
  end

  def extract_approvers
    if @raw_data['approvers'].present?
      @raw_data['approvers'] = @raw_data['approvers'].split(',')
      @data['approver_ids'] = User.where(email: @raw_data['approvers'].map(&:strip)).map(&:id)
      @error ||= @raw_data['approvers'].size != @data['approver_ids'].size
    else
      @error = true
    end
  end

  def extract_collaborators
    return if @raw_data['collaborators'].blank?
    @raw_data['collaborators'] = @raw_data['collaborators'].split(',')
    @data['collaborator_ids'] = User.where(email: @raw_data['collaborators'].map(&:strip)).map(&:id)
    @error ||= @raw_data['collaborators'].size != @data['collaborator_ids'].size
  end

  def fetch_allowed_field_from(raw_data)
    ALLOWED_FIELD.map { |field| [field, raw_data[field]] }.to_h
  end

  def parse(column)
    column.split(',').map { |s| s.strip.sub ' ', '_' }
  end

  def subset_of(items, available_items)
    (items - available_items).blank?
  end
end
