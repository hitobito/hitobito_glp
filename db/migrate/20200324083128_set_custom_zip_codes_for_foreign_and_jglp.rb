class SetCustomZipCodesForForeignAndJglp < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      UPDATE groups SET zip_codes = "#{SortingHat::FOREIGN_ZIP_CODE}"
      WHERE groups.type = 'Group::Kanton' AND groups.name = 'Ausland / étranger'
    SQL

    execute <<~SQL
      UPDATE groups SET zip_codes = "#{SortingHat::JGLP_ZIP_CODE}"
      WHERE groups.type = 'Group::Kanton' AND groups.name = 'jglp Schweiz'
    SQL
  end
end
