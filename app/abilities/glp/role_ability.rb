# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::RoleAbility
  extend ActiveSupport::Concern

  included do
    on(Role) do
      general(:create, :update).require_admin_permission_for_precious_roles
    end
  end

  def require_admin_permission_for_precious_roles
    user_context.admin || !precious_roles.include?(subject.class.sti_name.split('::').last)
  end

  def precious_roles
    %w(Administrator Adressverwaltung)
  end
end
