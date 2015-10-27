class RemoveCategoryandtypeFromChangeRequests < ActiveRecord::Migration
  def change
    remove_column :change_requests, :category, :string
    remove_column :change_requests, :cr_type, :string
  end
end
