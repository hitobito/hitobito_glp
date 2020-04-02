# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe MailingListAbility do
  let(:root)     { groups(:root) }
  let(:kanton)   { groups(:bern) }
  let(:bezirk)   { kanton.children.create!(type: 'Group::Bezirk', name: 'Stadt') }

  subject { Ability.new(person.reload) }

  def build_list(group)
    group.mailing_lists.build
  end

  context 'Root::Administrator' do
    let(:person)   { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)).person }

    %w(index_subscriptions export_subscriptions create update destroy).each do |action|
      it "may execute #{action} on mailing_list in kanton" do
        expect(subject).to be_able_to(action.to_sym, build_list(kanton))
      end

      it "may execute #{action} on mailing_list in bezirk below" do
        expect(subject).to be_able_to(action.to_sym, build_list(bezirk))
      end
    end
  end

  context 'Kanton::Administrator' do
    let(:person) {  Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)).person }

    %w(index_subscriptions export_subscriptions create update destroy).each do |action|
      it "may execute #{action} on mailing_list in kanton" do
        expect(subject).to be_able_to(action.to_sym, build_list(kanton))
      end

      it "may execute #{action} on mailing_list in bezirk" do
        expect(subject).to be_able_to(action.to_sym, build_list(bezirk))
      end

      it "may not execute #{action} on root" do
        expect(subject).not_to be_able_to(action.to_sym, build_list(root))
      end

      it "may not execute #{action} on sibling" do
        expect(subject).not_to be_able_to(action.to_sym, build_list(groups(:zurich)))
      end
    end
  end
end
