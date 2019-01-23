# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe PersonAbility do
  let(:administrator)    { Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)) }
  let(:root)             { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)) }


  subject { Ability.new(person.reload) }

  context :root do
    let(:person)   { root.person }
    let(:mitglied) { Fabricate(Group::KantonZugeordnete::Mitglied.name.to_sym, group: groups(:bern_zugeordnete)) }

    it 'may destroy person' do
      is_expected.to be_able_to(:destroy, mitglied.person)
    end
  end

  context :administrator do
    let(:person)          { administrator.person }
    let(:mitglied)        { Fabricate(Group::KantonZugeordnete::Mitglied.name.to_sym, group: groups(:bern_zugeordnete)) }
    let(:mitglied_zurich) { Fabricate(Group::KantonZugeordnete::Mitglied.name.to_sym, group: groups(:zurich_zugeordnete)) }

    it 'may destroy person if only role is in bern' do
      is_expected.to be_able_to(:destroy, mitglied.person)
    end

    it 'may not destroy person if only role is in zurich' do
      is_expected.not_to be_able_to(:destroy, mitglied_zurich.person)
    end

    it 'may not destroy person if roles in bern and zurich exist' do
      Fabricate(Group::KantonZugeordnete::Mitglied.name.to_sym, person: mitglied_zurich.person, group: groups(:bern_zugeordnete))
      is_expected.not_to be_able_to(:destroy, mitglied_zurich.person.reload)
    end
  end

end
