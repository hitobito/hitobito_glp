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
    prepend_before_action :puts_hello
    # def destroy
    #   super
    #   binding.pry
    # end
  end
  def puts_hello
    binding.pry
  end

  # Notify parent group and root group via email
  def notify_leadership
    binding.pry
    # zugeordnete_groups_where_he_is_a_mitglied = entry.zugeordnete_groups_where_he_is_a_mitglied

    # if zugeordnete_groups_where_he_is_a_mitglied.any?
    #   zugeordnete_groups_where_he_is_a_mitglied.each do |zugeordnete_group|
    #     if zugeordnete_group.parent.email.present?
    #       binding.pry
    #       notify_parent_group email
    #     end
    #   end
    #   # notify_root_group
    # end
  end

  def notify_parent_group email
    Notifier.mitglied_left(entry, email).deliver_now 
  end

  def notify_root_group
    Notifier.mitglied_left(entry, root_group.email).deliver_now 
  end
end
