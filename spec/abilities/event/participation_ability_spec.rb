# frozen_string_literal: true
#  Copyright (c) 2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe Event::ParticipationAbility do
  let(:root)     { groups(:root) }
  let(:kanton)   { groups(:bern) }
  let(:bezirk)   { kanton.children.create!(type: 'Group::Bezirk', name: 'Stadt') }

  subject { Ability.new(person.reload) }

  def event_participation(group)
    primary_event = Fabricate(:event, groups: [group])
    participation = Fabricate(
      :event_participation,
      person: people(:mitglied),
      event: primary_event,
      application: Fabricate(
        :event_application,
        priority_1: primary_event,
        priority_2: nil
      )
    )
    Fabricate(Event::Role::Participant.name.to_sym, participation: participation)

    participation
  end

  context 'Root::Administrator' do
    let(:person)   { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)).person }

    %w(create destroy).each do |action|
      it "may execute #{action} on event-particpation for event in kanton" do
        expect(subject).to be_able_to(action.to_sym, event_participation(kanton))
      end

      it "may execute #{action} on event-particpation for event in bezirk below" do
        expect(subject).to be_able_to(action.to_sym, event_participation(bezirk))
      end
    end
  end

  context 'Kanton::Administrator' do
    let(:person) {  Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)).person }

    %w(create destroy).each do |action|
      it "may execute #{action} on event-particpation for event in kanton" do
        expect(subject).to be_able_to(action.to_sym, event_participation(kanton))
      end

      it "may not execute #{action} on event-particpation for event in bezirk" do
        expect(subject).to_not be_able_to(action.to_sym, event_participation(bezirk))
      end

      it "may not execute #{action} on root" do
        expect(subject).not_to be_able_to(action.to_sym, event_participation(root))
      end

      it "may not execute #{action} on sibling" do
        expect(subject).not_to be_able_to(action.to_sym, event_participation(groups(:zurich)))
      end
    end
  end
end
