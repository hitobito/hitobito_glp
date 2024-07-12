# frozen_string_literal: true

#  Copyright (c) 2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::PersonReadables
  extend ActiveSupport::Concern

  included do
    alias_method_chain :group_accessible_people, :donor
    alias_method_chain :layer_and_below_read_in_same_layer?, :donor

    alias_method_chain :in_same_layer_condition, :donor
    alias_method_chain :accessible_conditions, :donor
  end

  def donor_visible?
    group_read_in_this_group? ||
      group_read_in_above_group? ||
      (financial_layers_ids & group.layer_hierarchy.map(&:id)).present?
  end

  private

  def accessible_conditions_with_donor
    accessible_conditions_without_donor.tap do |condition|
      financials_condition(condition)
      condition.delete(*contact_data_condition) if contact_data_visible?
    end
  end

  def group_accessible_people_with_donor
    if donor_group?
      can(:index, Person, scope_for_donor_group) { |_| true }
    else
      group_accessible_people_without_donor
    end
  end

  def scope_for_donor_group
    if donor_visible?
      group.people.only_public_data
    else
      group.people.only_public_data.merge(donor_accessible_condition)
    end
  end

  def donor_accessible_condition
    Person.visible_from_above(group).or(Person.where(*herself_condition))
  end

  def in_same_layer_condition_with_donor(condition)
    if layer_groups_same_layer.present?
      condition.or(*layer_group_query(layer_groups_same_layer.collect(&:id), without_donor_types))
    end
  end

  def layer_group_query(layer_group_ids, role_types)
    ["groups.layer_group_id IN (?) AND roles.type IN (?)",
      layer_group_ids, role_types.map(&:sti_name)]
  end

  def financials_condition(condition)
    return if financial_layers_ids.blank?

    additional_layer_ids = layer_groups_same_layer.collect(&:id) & financial_layers_ids
    query = layer_group_query(additional_layer_ids, Role.all_types)
    condition.or(*query)
  end

  def without_donor_types
    Role.all_types - [Group::Spender::Spender]
  end

  def layer_and_below_read_in_same_layer_with_donor?
    donor_group? ? false : layer_and_below_read_in_same_layer_without_donor?
  end

  def donor_group?
    group.is_a?(Group::Spender)
  end

  def financial_layers_ids
    @financial_layers_ids ||= user.groups_with_permission(:financials).map(&:layer_group_id)
  end
end
