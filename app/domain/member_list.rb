#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class MemberList
  KINDS = %w[
    members
    sympis
    members_and_sympis
  ]

  def initialize(template, group, kind)
    @template = template
    @layer_group = group.layer_group
    @kind = kind
  end

  def count
    Person::Filter::List.new(@layer_group,
      @template.current_user,
      params).all_count
  end

  def path(name:)
    @template.group_people_path(@layer_group, params.merge(name: name))
  end

  def key
    [@layer_group.class.to_s.demodulize.downcase, @kind].join(".")
  end

  private

  def params
    {
      range: "deep",
      filters: {role: {role_type_ids: role_type_ids}}
    }
  end

  def role_type_ids
    types = if @kind == "members"
      Role.all_types.select { |type| type.to_s =~ /Zugeordnete::Mitglied$/ }
    elsif @kind == "sympis"
      Role.all_types.select { |type| type.to_s =~ /Zugeordnete::Sympathisant$/ }
    elsif @kind == "members_and_sympis"
      Role.all_types.select { |type| type.to_s =~ /Zugeordnete::(Mitglied|Sympathisant)$/ }
    end
    types.collect(&:id).join(Person::Filter::Base::ID_URL_SEPARATOR)
  end
end
