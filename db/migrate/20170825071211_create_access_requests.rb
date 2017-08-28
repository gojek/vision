class CreateAccessRequests < ActiveRecord::Migration
  def change
    create_table :access_requests do |t|
      t.references :user, index: true, foreign_key: true

      t.string :request_type
      t.string :access_type
      t.date :start_date
      t.date :end_date
      
      t.string :employee_name
      t.string :employee_position
      t.string :employee_email_address
      t.string :employee_department
      t.string :employee_phone

      t.boolean :employee_access
      t.boolean :fingerprint_business_area
      t.boolean :fingerprint_business_operations
      t.boolean :fingerprint_it_operations
      t.boolean :fingerprint_server_room
      t.boolean :fingerprint_archive_room
      t.boolean :fingerprint_engineering_area

      t.string :corporate_email

      t.boolean :internet_access
      t.boolean :slack_access
      t.boolean :admin_tools
      t.boolean :vpn_access
      t.boolean :github_gitlab
      t.boolean :exit_interview
      t.boolean :access_card
      t.boolean :parking_cards
      t.boolean :id_card
      t.boolean :name_card
      t.boolean :insurance_card
      t.boolean :cash_advance

      t.boolean :password_reset
      t.string :user_identification
      t.string :asset_name

      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
