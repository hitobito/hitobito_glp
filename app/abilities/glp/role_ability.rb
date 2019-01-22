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
