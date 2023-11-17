# frozen_string_literal: true

#  Copyright (c) 2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::PersonDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :roles_grouped, :filtered_donor_roles
    alias_method_chain :filtered_roles, :donors_removed
  end

  private

  def filtered_roles_with_donors_removed(group, multiple_groups = false)
    filtered_roles_without_donors_removed(group, multiple_groups).select do |role|
      !role.is_a?(::Group::Spender::Spender) ||
        (role.person_id == current_user&.id || donor_visible?(group))
    end
  end

  def roles_grouped_with_filtered_donor_roles(scope: roles)
    roles_grouped_without_filtered_donor_roles(scope: scope).collect do |group, roles|
      next [group, roles] if !group.is_a?(Group::Spender) || donor_visible?(group)

      visible_roles = roles.select(&:visible_from_above?)
      [group, visible_roles] if visible_roles.present?
    end.compact.to_h
  end

  def donor_visible?(group)
    PersonReadables.new(h.current_user, group).donor_visible?
  end

  def donor_roles
    @donor_roles ||= subject.roles.select do |role|
      role.group.class.ancestors.include?(Group::Spender)
    end
  end

end
