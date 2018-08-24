# encoding: utf-8

#  Copyright (c) 2012-2018, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Glp::PeopleController
  extend ActiveSupport::Concern

  included do
    self.permitted_attrs += [:title, :preferred_language,
                             :joining_journey, :occupation,
                             :joined_at, :left_at, :website_url, :paperless]
    before_destroy :notify_leadership
  end

  def notify_leadership
    zugeordnete_roles_where_he_is_a_mitglied = entry.zugeordnete_roles_where_he_is_a_mitglied

    if zugeordnete_roles_where_he_is_a_mitglied.any?
      zugeordnete_parent_groups = zugeordnete_roles_where_he_is_a_mitglied.map(&:group).map(&:parent).uniq

      zugeordnete_parent_groups.each do |group|
        if group.email.present?
          notify_parent_group group.email
        end
      end
      notify_root_group
    end
  end

  def notify_parent_group email
    Notifier.mitglied_left(entry, email).deliver_now 
  end

  def notify_root_group
    root_group = Group.find_by_type("Group::Root")
    if root_group.email.present?
      Notifier.mitglied_left(entry, root_group.email).deliver_now 
    end
  end
end
