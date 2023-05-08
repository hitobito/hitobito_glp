# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::RoleAbility
  extend ActiveSupport::Concern

  included do
    on(Role) do
      general(:create, :update).require_relevant_create_update_permissions

      general(:show, :destroy).require_financials_permission_for_financial_roles
    end
  end

  def require_relevant_create_update_permissions
    require_admin_permission_for_precious_roles &&
      require_financials_permission_for_financial_roles &&
      require_create_spendenverwalter_permission_for_spendenverwalter_role
  end

  def require_admin_permission_for_precious_roles
    !precious_roles.include?(subject.class.sti_name.split('::').last) || user_context.admin
  end

  def require_financials_permission_for_financial_roles
    subject.permissions.exclude?(:financials) || user.groups_with_permission(:financials).any?
  end

  def require_create_spendenverwalter_permission_for_spendenverwalter_role
    subject.class.sti_name.demodulize != 'Spendenverwalter' ||
      user_context.all_permissions.include?(:create_spendenverwalter) &&
      contains_any?(
        subject.group.layer_hierarchy.map(&:id),
        user_context.permission_layer_ids(:create_spendenverwalter)
      )
  end

  def precious_roles
    %w(Administrator Adressverwaltung)
  end
end
