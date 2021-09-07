class AddAttributesToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :definition_of_success, :text
    add_column :change_requests, :definition_of_failed, :text
    add_column :change_requests, :category_application, :boolean
    add_column :change_requests, :category_network_equipment, :boolean
    add_column :change_requests, :category_server, :boolean
    add_column :change_requests, :category_user_access, :boolean
    add_column :change_requests, :category_other, :string
    add_column :change_requests, :type_security_update, :boolean
    add_column :change_requests, :type_install_uninstall, :boolean
    add_column :change_requests, :type_configuration_change, :boolean
    add_column :change_requests, :type_emergency_change, :boolean
    add_column :change_requests, :type_other, :string
  end
end
