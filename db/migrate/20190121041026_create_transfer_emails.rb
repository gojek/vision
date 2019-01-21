class CreateTransferEmails < ActiveRecord::Migration
  def change
    create_table :transfer_emails do |t|
      t.string :old_email
      t.string :new_email
      t.boolean :is_changed, default: false

      t.timestamps null: false
    end
  end
end
