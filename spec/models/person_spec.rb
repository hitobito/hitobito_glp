require 'spec_helper'

describe Person do

  context 'simplified_view' do
    let(:person) { Person.new }
    subject      { person.simplified_view? }

    it 'is true for person without roles' do
      expect(subject).to eq true
    end

    it 'is true for person with single Mitglied role' do
      build(:root_zugeordnete, Group::RootZugeordnete::Mitglied)
      expect(subject).to eq true
    end

    it 'is true for person with single Sympathisant role' do
      build(:root_zugeordnete, Group::RootZugeordnete::Sympathisant)
      expect(subject).to eq true
    end

    it 'is true for person with single Kontakt role' do
      build(:root_kontakte, Group::RootKontakte::Kontakt)
      expect(subject).to eq true
    end

    it 'is true for person with single Spender role' do
      build(:root, Group::Spender::Spender)
      expect(subject).to eq true
    end

    it 'is true for person with multiple of those roles' do
      build(:root_kontakte, Group::RootKontakte::Kontakt)
      build(:root_zugeordnete, Group::RootZugeordnete::Adressverwaltung)
      expect(subject).to eq false
    end

    it 'is false for person with any other role type' do
      build(:root_zugeordnete, Group::RootZugeordnete::Adressverwaltung)
      expect(subject).to eq false
    end

    it 'is false for person with any other role type and Kontakt role' do
      build(:root_zugeordnete, Group::RootZugeordnete::Adressverwaltung)
      build(:root_kontakte, Group::RootKontakte::Kontakt)
      expect(subject).to eq false
    end

    def build(group, type)
      person.roles.build(group: groups(group), type: type.sti_name)
    end
  end

  context 'zip_code' do
    let(:person) { Person.new(first_name: 'a', last_name: 'b', email: 'a@b.com') }
    it 'accepts anything as zip_code' do
      expect(person).to be_valid
      person.zip_code = 1
      expect(person).to be_valid
    end
  end
end
