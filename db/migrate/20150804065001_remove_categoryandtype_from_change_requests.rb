class RemoveCategoryandtypeFromChangeRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :change_requests, :category, :string
    remove_column :change_requests, :cr_type, :string
  end
end
