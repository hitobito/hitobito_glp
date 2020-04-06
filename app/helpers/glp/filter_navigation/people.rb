# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::FilterNavigation::People

  def init_kind_filter_names
    super

    @kind_filter_names[:layer_members] = label if member_list.applies?
  end

  def init_kind_items
    super

    if member_list.applies?
      item(label, member_list.path(name: label), member_list.count)
    end
  end

  def label
    translate(member_list.key)
  end

  def member_list
    @member_list ||= MemberList.new(template, group)
  end

end
