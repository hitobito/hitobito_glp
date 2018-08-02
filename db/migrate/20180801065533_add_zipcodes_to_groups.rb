class AddZipcodesToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :zip_codes, :string
  end
end
