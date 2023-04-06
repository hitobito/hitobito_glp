# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe RoleAbility do
  let(:root)             { Fabricate(Group::Root::Administrator.name.to_sym, group: groups(:root)) }
  let(:administrator)    { Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)) }
  let(:spendenverwaltung) { Fabricate(Group::Kanton::Spendenverwalter.name.to_sym, group: groups(:bern)) }
  let(:adressverwaltung) { Fabricate(Group::KantonZugeordnete::Adressverwaltung.name.to_sym, group: groups(:bern_zugeordnete)) }
  let(:mitglied)         { Fabricate(Group::KantonZugeordnete::Mitglied.name.to_sym, group: groups(:bern_zugeordnete)) }

  subject { Ability.new(person.reload) }

  context :root_admin do
    let(:person)  { root.person }

    it 'may create Administrator' do
      is_expected.to be_able_to(:create, administrator)
    end

    it 'may create Versandaddresse' do
      is_expected.to be_able_to(:create, adressverwaltung)
    end

    it 'may create Mitglied' do
      is_expected.to be_able_to(:create, mitglied)
    end

    it 'may not create Spendenverwalter' do
      is_expected.to_not be_able_to(:create, spendenverwaltung)
    end
  end

  context :kanton_admin do
    let(:person)  { administrator.person }

    it 'may not create Administrator' do
      is_expected.not_to be_able_to(:create, administrator)
    end

    it 'may not create Versandaddresse' do
      is_expected.not_to be_able_to(:create, adressverwaltung)
    end

    it 'may create Mitglied' do
      is_expected.to be_able_to(:create, mitglied)
    end

    it 'may not create Spendenverwalter' do
      is_expected.to_not be_able_to(:create, spendenverwaltung)
    end
  end

  context :kanton_spendenverwaltung do
    let(:person)  { spendenverwaltung.person }

    it 'may not create Administrator' do
      is_expected.not_to be_able_to(:create, administrator)
    end

    it 'may not create Versandaddresse' do
      is_expected.not_to be_able_to(:create, adressverwaltung)
    end

    it 'may create Mitglied' do
      is_expected.to be_able_to(:create, mitglied)
    end

    it 'may not create Spendenverwalter' do
      is_expected.not_to be_able_to(:create, spendenverwaltung)
    end
  end

  context :glp_spendenverwaltung do
    let(:person) { Fabricate(Group::Root::Spendenverwalter.name.to_sym, group: groups(:root)).person }

    it 'may create Spendenverwalter' do
      is_expected.not_to be_able_to(:create, spendenverwaltung)
    end
  end
end
