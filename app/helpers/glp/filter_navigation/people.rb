#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::FilterNavigation::People
  def init_kind_filter_names
    super

    MemberList::KINDS.take(1).each do |kind|
      member_list = MemberList.new(template, group, kind)
      @kind_filter_names[kind] = label(member_list.key) # rubocop:disable Rails/HelperInstanceVariable
    end
  end

  def init_kind_items
    super

    MemberList::KINDS.each_with_index do |kind, index|
      member_list = MemberList.new(template, group, kind)
      name = label(member_list.key)

      if index.zero?
        item(name, member_list.path(name: name), member_list.count)
      else
        dropdown.add_item(name, member_list.path(name: name))
      end
    end
  end

  def root?
    group.layer_group.is_a?(Group::Root)
  end

  def label(key)
    translate(key)
  end
end
