class SetCustomZipCodesForForeignAndJglp < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      UPDATE #{Group.quoted_table_name} SET zip_codes = "#{SortingHat::FOREIGN_ZIP_CODE}"
      WHERE #{Group.quoted_table_name}.type = 'Group::Kanton'
      AND #{Group.quoted_table_name}.name = 'Ausland / étranger'
    SQL

    execute <<~SQL
      UPDATE #{Group.quoted_table_name} SET zip_codes = "#{SortingHat::JGLP_ZIP_CODE}"
      WHERE #{Group.quoted_table_name}.type = 'Group::Kanton'
      AND #{Group.quoted_table_name}.name = 'jglp Schweiz'
    SQL
  end
end
