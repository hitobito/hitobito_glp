class AddPaperlessToPerson < ActiveRecord::Migration
  def change
    add_column :people, :paperless, :boolean, default: false
  end
end
