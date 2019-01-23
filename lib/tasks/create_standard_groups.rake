# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'dotenv/tasks'

namespace :master_data do
  task create_standard_groups: :environment do
    groups_to_create = [
      {
        parent: Group::Kanton,
        children_types: [
          [Group::KantonZugeordnete, "Mitglieder & Sympathisanten"],
          [Group::KantonKontakte, "Medien & Dritte"],
          [Group::KantonDelegierte, "Delegierte"],
          [Group::KantonGewaehlte, "Mandatsträger"],
          [Group::KantonVorstand, "Vorstand"]
        ]
      },
      {
        parent: Group::Bezirk,
        children_types: [
          [Group::BezirkZugeordnete, "Mitglieder & Sympathisanten"],
          [Group::BezirkKontakte, "Medien & Dritte"],
          [Group::BezirkVorstand, "Vorstand"]
        ]
      },
      {
        parent: Group::Ortsektion,
        children_types: [
          [Group::OrtsektionZugeordnete, "Mitglieder & Sympathisanten"],
          [Group::OrtsektionKontakte, "Medien & Dritte"],
          [Group::OrtsektionVorstand, "Vorstand"]
        ]
      }
    ]
    groups_to_create.each do |layer|
      parent = layer[:parent]
      children_types = layer[:children_types]
      Group.where(type: parent.to_s).each do |parent_group|
        children_types.each do |children_type|
          type, name_prefix = children_type
          unless parent_group.children.where(type: type.to_s).any?
            parent_group.children.create!(
              type: type.to_s,
              name: "#{name_prefix} #{parent_group.name}"
            )
          end
        end
      end
    end
  end
end
