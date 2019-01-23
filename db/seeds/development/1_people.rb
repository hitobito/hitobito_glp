# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


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
