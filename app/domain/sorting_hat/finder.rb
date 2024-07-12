# frozen_string_literal: true

#  Copyright (c) 2012-2023, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module SortingHat
  class Finder
    def initialize(role, zip, jglp)
      @role = role
      @zip = zip
      @jglp = jglp
    end

    def groups # rubocop:disable Metrics/AbcSize
      groups = if jglp?
        inside_jglp = find_for_zip(jglp_root.descendants)
        inside_jglp += group_for_role(jglp_root.children) if inside_jglp.none?
        inside_jglp + find_for_zip(root.descendants.where.not(id: subtree_jglp))
      elsif !foreign?
        find_for_zip(root.descendants.where.not(id: subtree_jglp))
      end
      Array.wrap(groups.presence || fallback)
    end

    private

    def find_for_zip(scope = root.descendants)
      return Group.none if @zip.blank?
      return Group.none if foreign?

      scope = scope.without_deleted.joins(:parent)
        .where("parents_groups.zip_codes LIKE ?", "%#{@zip}%")
        .where(parents_groups: {deleted_at: nil})

      group_for_role(scope)
    end

    def fallback
      group = jglp_root if @jglp
      group ||= foreign_root if foreign?
      group ||= root

      group_for_role(group.children).presence || group_for_role(root.children)
    end

    def group_for_role(scope)
      return Group.none unless scope

      scope = scope.where("groups.type LIKE ?", "%#{SortingHat::ROLES.fetch(@role)}")
      groups = scope.without_deleted
      groups.one? ? groups : Group.none
    end

    def root
      @root ||= without_deleted.root
    end

    def foreign_root
      @foreign_root ||= without_deleted.find_by(zip_codes: SortingHat::FOREIGN_ZIP_CODE)
    end

    def jglp_root
      @jglp_root ||= without_deleted.find_by(zip_codes: SortingHat::JGLP_ZIP_CODE)
    end

    def subtree_jglp
      if jglp_root
        without_deleted.where("lft > ? AND rgt < ?", jglp_root.lft, jglp_root.rgt)
      else
        Group.none
      end
    end

    def foreign?
      foreign_root && @zip.present? && @zip.to_s.length != 4
    end

    def jglp?
      jglp_root && @jglp
    end

    def without_deleted
      Group.without_deleted
    end
  end
end
