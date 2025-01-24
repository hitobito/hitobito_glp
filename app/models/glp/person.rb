# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::Person
  extend ActiveSupport::Concern

  PREFERRED_LANGUAGES = [:en, :de, :fr, :it]
  SIMPLIFIED_VIEW_ROLES = %w[Kontakt Sympathisant Mitglied Spender]

  included do
    self.validate_zip_code = false

    Person::PUBLIC_ATTRS << :title << :preferred_language
    alias_method_chain :full_name, :title
    scope :admin, -> { joins(:roles).where("roles.type LIKE '%::Administrator'") }
    scope :notify_on_join, -> { where(notify_on_join: true) }
  end

  def admin?
    roles.any? { |role| role.type =~ /::Administrator/ }
  end

  def full_name_with_title(format = :default)
    case format
    when :list, :print_list then "#{title} #{full_name_without_title(format)}".strip
    else "#{title} #{full_name_without_title}".strip
    end
  end

  def zugeordnete_roles_where_he_is_a_mitglied
    roles.select { |role| role.type.include? "Zugeordnete" and role.type.include? "Mitglied" }
  end

  def simplified_view?
    roles.all? { |role| SIMPLIFIED_VIEW_ROLES.include?(role.class.to_s.demodulize) } && !root?
  end
end
