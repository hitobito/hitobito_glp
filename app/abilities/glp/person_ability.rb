# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::PersonAbility
  extend ActiveSupport::Concern

  included do
    on(Person) do
      permission(:any).may(:destroy).if_admin_same_or_above
    end
  end

  def if_admin_same_or_above
    not_self && precious_role_above?
  end

  private

  def precious_role_above?
    subject_hierarchy_group_ids.all? do |hierarchy_ids|
      precious_roles_group_ids.any? { |id| hierarchy_ids.include?(id) }
    end
  end

  def precious_roles_group_ids
    @precious_roles_group_ids ||= user.roles.select do |role|
      precious_roles.include?(role.class.sti_name.split('::').last)
    end.collect(&:group_id)
  end

  def subject_hierarchy_group_ids
    subject.roles.collect { |role| role.group.hierarchy.collect(&:id) }
  end

  def precious_roles
    %w(Administrator Adressverwaltung)
  end
end
