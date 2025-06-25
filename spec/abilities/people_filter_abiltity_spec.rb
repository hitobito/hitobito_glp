#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe PeopleFilterAbility do
  let(:root) { groups(:root) }
  let(:kanton) { groups(:bern) }
  let(:bezirk) { kanton.children.create!(type: "Group::Bezirk", name: "Stadt") }

  subject { Ability.new(person.reload) }

  def build_filter(group)
    group.people_filters.build(name: "test", filter_chain: {role: {role_type_ids: []}})
  end

  context "Root::Administrator" do
    let(:person) { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)).person }

    %w[create destroy edit update].each do |action|
      it "may execute #{action} on people_filter in kanton" do
        expect(subject).to be_able_to(action.to_sym, build_filter(kanton))
      end

      it "may execute #{action} on people_filter in bezirk below" do
        expect(subject).to be_able_to(action.to_sym, build_filter(bezirk))
      end
    end
  end

  context "Kanton::Administrator" do
    let(:person) { Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)).person }

    %w[create destroy edit update].each do |action|
      it "may execute #{action} on people_filter in kanton" do
        expect(subject).to be_able_to(action.to_sym, build_filter(kanton))
      end

      it "may execute #{action} on people_filter in bezirk" do
        expect(subject).to be_able_to(action.to_sym, build_filter(bezirk))
      end

      it "may not execute #{action} on root" do
        expect(subject).not_to be_able_to(action.to_sym, build_filter(root))
      end

      it "may not execute #{action} on sibling" do
        expect(subject).not_to be_able_to(action.to_sym, build_filter(groups(:zurich)))
      end
    end
  end
end
