# frozen_string_literal: true

#  Copyright (c) 2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe ServiceTokenAbility do
  let(:root) { groups(:root) }
  let(:kanton) { groups(:bern) }
  let(:bezirk) { kanton.children.create!(type: "Group::Bezirk", name: "Stadt") }

  subject { Ability.new(person.reload) }

  def service_token(group)
    Fabricate(:service_token, layer: group)
  end

  context "Root::Administrator" do
    let(:person) { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)).person }

    %w[update show edit destroy].each do |action|
      it "may execute #{action} in kanton" do
        expect(subject).to be_able_to(action.to_sym, service_token(kanton))
      end

      it "may execute #{action} on mailing_list in bezirk below" do
        expect(subject).to be_able_to(action.to_sym, service_token(bezirk))
      end
    end
  end

  context "Kanton::Administrator" do
    let(:person) { Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)).person }

    %w[update show edit destroy].each do |action|
      it "may execute #{action} in kanton" do
        expect(subject).to be_able_to(action.to_sym, service_token(kanton))
      end

      it "may not execute #{action} in bezirk" do
        expect(subject).not_to be_able_to(action.to_sym, service_token(bezirk))
      end

      it "may not execute #{action} on root" do
        expect(subject).not_to be_able_to(action.to_sym, service_token(root))
      end

      it "may not execute #{action} on sibling" do
        expect(subject).not_to be_able_to(action.to_sym, service_token(groups(:zurich)))
      end
    end
  end
end
