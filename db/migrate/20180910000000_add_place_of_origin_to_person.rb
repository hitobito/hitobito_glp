class AddPlaceOfOriginToPerson < ActiveRecord::Migration
  def change
    add_column :people, :place_of_origin, :string, default: nil
  end
end
