# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class MemberList

  def initialize(template, group,  range = 'deep')
    @template  = template
    @layer_group = find_layer_group(group)
    @range = range
  end

  def count
    Person::Filter::List.new(@layer_group,
                             @template.current_user,
                             params).all_count
  end

  def path(name: )
    @template.group_people_path(@layer_group, params.merge(name: name))
  end

  def applies?
    !(root_layer? || special_layer?)
  end

  def key
    [@layer_group.class.to_s.demodulize.downcase, 'layer_members'].join('_')
  end


  private

  def root_layer?
    @layer_group.is_a?(Group::Root)
  end

  def special_layer?
    [SortingHat::FOREIGN_ZIP_CODE, SortingHat::JGLP_ZIP_CODE].any? do |code|
      code.to_s == @layer_group.zip_codes
    end
  end

  def find_layer_group(group)
    case group.layer_group
    when Group::Root, Group::Kanton then group.layer_group
    else find_layer_group(group.layer_group.parent)
    end
  end

  def params
    {
      range: @range,
      filters: { role: { role_type_ids: role_type_ids } }
    }
  end

  def role_type_ids
    types = Role.all_types.select { |type| type.to_s =~ /Zugeordnete::Mitglied$/ }
    types.collect(&:id).join(Person::Filter::Base::ID_URL_SEPARATOR)
  end

end
