# frozen_string_literal: true

#  Copyright (c) 2022, GLP Schweiz. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

require 'spec_helper'

describe PersonReadables do

  [:index, :layer_search, :deep_search, :global].each do |action|
    context action do
      let(:user)   { role.person.reload }
      let(:ability) { PersonReadables.new(user, action == :index ? group : nil) }

      let(:all_accessibles) do
        people = Person.accessible_by(ability)
        case action
        when :index then people
        when :layer_search then people.in_layer(group.layer_group)
        when :deep_search then people.in_or_below(group.layer_group)
        when :global then people
        end
      end

      subject { all_accessibles }

      describe 'layer_and_below_full on upper layer' do
        let(:role) { Fabricate(Group::Root::Administrator.name, group: groups(:root)) }

        it 'has layer and below full permission' do
          expect(role.permissions).to include(:layer_and_below_full)
        end

        context 'lower spender group' do
          let(:group) { Fabricate(Group::Spender.name, parent: groups(:root)) }

          it 'may not get spender people' do
            other = Fabricate(Group::Spender::Spender.name, group: group)
            is_expected.not_to include(other.person)
          end
        end

        xcontext 'lower stufe group' do
          # let(:group) { groups(:) }

          it 'may not get non-visible people' do
            other = Fabricate(Group::Stufe::Teilnehmer.name, group: group)
            is_expected.not_to include(other.person)
          end
        end
      end

      describe 'layer_and_below_full on same layer' do
        let(:role) { Fabricate(Group::Kanton::Administrator.name, group: groups(:bern)) }


        context 'spender group' do
          let(:group) { Fabricate(Group::Spender.name, parent: groups(:bern)) }

          it 'may not get spender people' do
            other = Fabricate(Group::Spender::Spender.name, group: group)
            is_expected.not_to include(other.person)
          end
        end
      end

      describe 'financials on same layer' do
        let(:role) { Fabricate(Group::Kanton::Spendenverwalter.name, group: groups(:bern)) }

        context 'lower spender group' do
          let(:group) { Fabricate(Group::Spender.name, parent: groups(:bern)) }

          it 'may get spender people' do
            other = Fabricate(Group::Spender::Spender.name, group: group)
            is_expected.to include(other.person)
          end
        end
      end
    end
  end
end
