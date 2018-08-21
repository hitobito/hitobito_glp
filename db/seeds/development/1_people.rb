# encoding: utf-8

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class GlpPersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name.demodulize
    when 'Member' then 5
    else 1
    end
  end

end

devs = {'Mat' => 'mat@zeilenwerk.ch', 'Zeilenwerk' => 'test@zeilenwerk.ch'} # add accounts for 'live' test users

seeder = GlpPersonSeeder.new

seeder.seed_all_roles

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Root::Administrator)
end
