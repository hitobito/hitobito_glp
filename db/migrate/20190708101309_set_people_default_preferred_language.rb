class SetPeopleDefaultPreferredLanguage < ActiveRecord::Migration
  def up
    change_column_default(:people, :preferred_language, to: :de)
  end

  def down
    change_column_default(:people, :preferred_language, to: nil)
  end
end
