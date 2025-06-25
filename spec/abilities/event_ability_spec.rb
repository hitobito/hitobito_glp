#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe EventAbility do
  let(:root) { groups(:root) }
  let(:kanton) { groups(:bern) }
  let(:bezirk) { kanton.children.create!(type: "Group::Bezirk", name: "Stadt") }

  subject { Ability.new(person.reload) }

  def build_event(group)
    group.events.new.tap { |e| e.groups << group }
  end

  context "Root::Administrator" do
    let(:person) { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)).person }

    %w[create destroy application_market qualify qualifications_read].each do |action|
      it "may execute #{action} on event in kanton" do
        expect(subject).to be_able_to(action.to_sym, build_event(kanton))
      end

      it "may execute #{action} on event in bezirk below" do
        expect(subject).to be_able_to(action.to_sym, build_event(bezirk))
      end
    end
  end

  context "Kanton::Administrator" do
    let(:person) { Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)).person }

    %w[create destroy application_market qualify qualifications_read].each do |action|
      it "may execute #{action} on event in kanton" do
        expect(subject).to be_able_to(action.to_sym, build_event(kanton))
      end

      it "may execute #{action} on event in bezirk" do
        expect(subject).to be_able_to(action.to_sym, build_event(bezirk))
      end

      it "may not execute #{action} on root" do
        expect(subject).not_to be_able_to(action.to_sym, build_event(root))
      end

      it "may not execute #{action} on sibling" do
        expect(subject).not_to be_able_to(action.to_sym, build_event(groups(:zurich)))
      end
    end
  end
end
