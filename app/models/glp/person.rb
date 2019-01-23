# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::Person
  extend ActiveSupport::Concern

  PREFERRED_LANGUAGES = [:en, :de, :fr, :it]

  included do
    Person::PUBLIC_ATTRS << :title
    alias_method_chain :full_name, :title
  end

  def two_factor_authentication_required?
    roles.any? { |role| role.class.sti_name =~ /Administrator$/ }
  end

  def full_name_with_title(format = :default)
    case format
    when :list, :print_list then "#{title} #{full_name_without_title(format)}".strip
    else "#{title} #{full_name_without_title}".strip
    end
  end

  def zugeordnete_roles_where_he_is_a_mitglied
    roles.select{|role| role.type.include? "Zugeordnete" and role.type.include? "Mitglied"}
  end
end
