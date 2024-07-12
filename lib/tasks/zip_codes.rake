namespace :zip_codes do
  desc "List groups with duplicate zips"
  task duplicates: [:environment] do
    ZipCodes.new.print_duplicates
  end
end

class ZipCodes
  def zip_codes_with_group_ids
    groups_with_zips = Group.order(:layer_group_id).with_zip_codes.pluck(:id, :zip_codes)
    groups_with_zips.each_with_object({}) do |(group_id, zip_codes_string), memo|
      zip_codes = zip_codes_string.split(",")
      zip_codes.each do |zip_code|
        memo[zip_code] ||= []
        memo[zip_code] << group_id
      end
    end
  end

  def groups_with_duplicate_zip_codes
    duplicates = zip_codes_with_group_ids.reject { |_, v| v.one? }
    duplicates.each_with_object({}) do |(zip_code, group_ids), memo|
      memo[group_ids] ||= []
      memo[group_ids] << zip_code
    end
  end

  def print_duplicates
    duplicates = groups_with_duplicate_zip_codes
    groups = Group.where(id: duplicates.keys.flatten).index_by(&:id)

    duplicates.collect do |group_ids, zip_codes|
      group_string = groups.slice(*group_ids).values.collect do |g|
        deleted = g.deleted?
        name = deleted ? "#{g} - Gelöscht" : g.to_s
        "#{name} (#{g.id})"
      end.join(", ")
      puts "#{group_string} #{zip_codes.join(",")}"
    end
  end
end
