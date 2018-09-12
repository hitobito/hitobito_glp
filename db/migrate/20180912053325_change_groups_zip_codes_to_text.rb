class ChangeGroupsZipCodesToText < ActiveRecord::Migration
  def change
    change_column :groups, :zip_codes, :text
  end
end
