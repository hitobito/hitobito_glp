require 'spec_helper'

describe SortingHat do
  let(:person) { Fabricate(:person) }
  let(:notifier) { @notifier }

  before { @notifier = class_double("Notifier").as_stubbed_const.as_null_object }

  describe 'Mitglied' do
    let(:role)           {  'Mitglied' }
    let(:jglp)           {  false }
    let(:new_role)       {  person.roles.last }

    it 'notifies person and monitoring email address' do
      expect(notifier).to receive(:welcome_mitglied).with(person, 'de')
      expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
                                                                    role,
                                                                    SortingHat::MONITORING_EMAIL,
                                                                    jglp)
      SortingHat.new(person, role, jglp).sing
    end

    it 'notifies person in preferred_language' do
      person.update!(preferred_language: 'fr')
      expect(notifier).to receive(:welcome_mitglied).with(person, 'fr')
      SortingHat.new(person.reload, role, jglp).sing
    end

    context :zip_code do
      before do
        groups(:root).update(email: 'root@example.com')
        groups(:bern).update(zip_codes: '3000,3001', email: 'be@example.com')
      end

      it 'puts person in Kanton with matching zip' do
        person.update(zip_code: 3000)
        expect(notifier).to receive(:mitglied_joined).with(person, 'be@example.com', jglp)
        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:bern_zugeordnete)
      end

      it 'puts person in root group' do
        expect(notifier).to receive(:mitglied_joined).with(person, 'root@example.com', jglp)

        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end
    end
  end

  describe 'Sympathisant' do
    let(:role)           {  'Sympathisant' }
    let(:jglp)           {  false }
    let(:new_role)       {  person.roles.last }

    it 'notifies person and monitoring email address' do
      expect(notifier).to receive(:welcome_sympathisant).with(person, 'de')
      expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
                                                                    role,
                                                                    SortingHat::MONITORING_EMAIL,
                                                                    jglp)
      SortingHat.new(person, role, jglp).sing
    end

    it 'notifies person in preferred_language' do
      person.update!(preferred_language: 'fr')
      expect(notifier).to receive(:welcome_sympathisant).with(person, 'fr')
      SortingHat.new(person.reload, role, jglp).sing
    end

    context :zip_code do
      before do
        groups(:root).update(email: 'root@example.com')
        groups(:bern).update(zip_codes: '3000,3001', email: 'be@example.com')
      end

      it 'puts person in Kanton with matching zip' do
        person.update(zip_code: 3000)
        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
        expect(new_role.group).to eq groups(:bern_zugeordnete)
      end

      it 'puts person in root group' do
        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Sympathisant)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end
    end
  end

  describe 'Medien_und_dritte' do
    let(:role)           {  'Medien_und_dritte' }
    let(:jglp)           {  false }
    let(:new_role)       {  person.roles.last }

    it 'notifies person and monitoring email address' do
      expect(notifier).to receive(:welcome_medien_und_dritte).with(person, 'de')
      expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
                                                                    role,
                                                                    SortingHat::MONITORING_EMAIL,
                                                                    jglp)
      SortingHat.new(person, role, jglp).sing
    end

    it 'notifies person in preferred_language' do
      person.update!(preferred_language: 'fr')
      expect(notifier).to receive(:welcome_medien_und_dritte).with(person, 'fr')
      SortingHat.new(person.reload, role, jglp).sing
    end

    context :zip_code do
      before do
        groups(:root).update(email: 'root@example.com')
        groups(:bern).update(zip_codes: '3000,3001', email: 'be@example.com')
      end

      it 'puts person in Kanton with matching zip' do
        person.update(zip_code: 3000)
        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
        expect(new_role.group).to eq groups(:bern_kontakte)
      end

      it 'puts person in root group' do
        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootKontakte::Kontakt)
        expect(new_role.group).to eq groups(:root_kontakte)
      end
    end
  end

  it '.locked? is true for top level foreign and jglp groups' do
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: SortingHat::FOREIGN_ZIP_CODE))).to eq true
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: SortingHat::JGLP_ZIP_CODE))).to eq true
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: 'other'))).to eq false
  end
end
