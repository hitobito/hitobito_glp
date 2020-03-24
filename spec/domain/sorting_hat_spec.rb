require 'spec_helper'

describe SortingHat do
  let(:person) { Fabricate(:person) }
  let(:root)   { groups(:root) }
  let(:bern)   { groups(:bern) }

  let(:foreign_zip_code) { SortingHat::FOREIGN_ZIP_CODE }
  let(:jglp_zip_code)    { SortingHat::JGLP_ZIP_CODE }
  let(:jglp)             {  false }

  let(:notifier)         { @notifier }
  let(:new_role)         {  person.roles.last }

  before { @notifier = class_double("Notifier").as_stubbed_const.as_null_object }

  def update_email_and_zip_codes
    root.update(email: 'root@example.com')
    bern.update(zip_codes: '3000,3001', email: 'be@example.com')
  end

  def create_foreign_subtree
    @foreign = Group::Kanton.create!(name: 'Ausland', parent: root, zip_codes: foreign_zip_code)
    @foreign_kontakte = Group::KantonKontakte.create!(name: 'Kontakte', parent: @foreign)
    @foreign_zugeordnete = Group::KantonZugeordnete.create!(name: 'Zugeordnete', parent: @foreign)
  end

  def create_jglp_subtree
    @jglp = Group::Kanton.create!(name: 'jGLP', parent: root, zip_codes: jglp_zip_code, email: 'jglp@example.com')
    @jglp_kontakte = Group::KantonKontakte.create!(name: 'Kontakte', parent: @jglp)
    @jglp_zugeordnete = Group::KantonZugeordnete.create!(name: 'Zugeordnete', parent: @jglp)
  end

  def create_jglp_be_subtree
    @jglp_be = Group::Bezirk.create!(name: 'be', parent: @jglp, zip_codes: '3000', email: 'jglp_be@example.com')
    @jglp_be_kontakte = Group::BezirkKontakte.create!(name: 'Kontakte', parent: @jglp_be)
    @jglp_be_zugeordnete = Group::BezirkZugeordnete.create!(name: 'Zugeordnete', parent: @jglp_be)
  end

  it 'raises on invalid role' do
    expect do
      SortingHat.new(person, 'Admin', jglp).sing
    end.to raise_exception(ArgumentError)
  end

  it '.locked? is true for top level foreign and jglp groups' do
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: SortingHat::FOREIGN_ZIP_CODE))).to eq true
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: SortingHat::JGLP_ZIP_CODE))).to eq true
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: 'other'))).to eq false
  end

  describe 'Mitglied' do
    let(:role)           {  'Mitglied' }

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

    context :jglp do
      let(:jglp) { true }

      before { create_jglp_subtree }

      it 'puts person in top level jglp group' do
        expect(notifier).to receive(:mitglied_joined).with(person, 'jglp@example.com', jglp)

        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        expect(new_role.group).to eq @jglp_zugeordnete
      end
    end


    context :zip_code do
      before { update_email_and_zip_codes }

      it 'puts person in Kanton with matching zip' do
        person.update(zip_code: 3000)
        expect(notifier).to receive(:mitglied_joined).with(person, 'be@example.com', jglp)
        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:bern_zugeordnete)
      end

      it 'puts person in root group if multiple zips match' do
        groups(:zurich).update(zip_codes: '3000')
        person.update(zip_code: 3000)
        expect(notifier).to receive(:mitglied_joined).with(person, 'root@example.com', jglp)

        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end

      it 'puts person in root group' do
        expect(notifier).to receive(:mitglied_joined).with(person, 'root@example.com', jglp)

        SortingHat.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end

      context :jglp do
        let(:jglp) { true }

        before do
          create_jglp_subtree
          create_jglp_be_subtree
        end

        it 'puts person in Bezirk with matching zip' do
          person.update(zip_code: 3000)
          expect(notifier).to receive(:mitglied_joined).with(person, 'jglp_be@example.com', jglp)

          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::BezirkZugeordnete::Mitglied)
          expect(new_role.group).to eq @jglp_be_zugeordnete
        end

        it 'puts person top level jglp group without matching zip' do
          person.update(zip_code: 3001)
          expect(notifier).to receive(:mitglied_joined).with(person, 'jglp@example.com', jglp)

          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
          expect(new_role.group).to eq @jglp_zugeordnete
        end

        it 'puts person top level jglp group with foreign zip' do
          person.update(zip_code: 90210)
          expect(notifier).to receive(:mitglied_joined).with(person, 'jglp@example.com', jglp)

          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
          expect(new_role.group).to eq @jglp_zugeordnete
        end
      end

      context :foreign_zip_code do
        before { create_foreign_subtree }

        it 'puts person in bern group for matching zip' do
          person.update(zip_code: 3000)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
          expect(new_role.group).to eq groups(:bern_zugeordnete)
        end

        it 'puts person in foreign group for more than 4 digits' do
          person.update(zip_code: 90210)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        end

        it 'puts person in foreign group for less than 4 digits' do
          person.update(zip_code: 210)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        end
      end
    end
  end

  describe 'Sympathisant' do
    let(:role)           {  'Sympathisant' }

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
      before { update_email_and_zip_codes }

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

      context :foreign_zip_code do
        before { create_foreign_subtree }

        it 'puts person in bern group for matching zip' do
          person.update(zip_code: 3000)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
          expect(new_role.group).to eq groups(:bern_zugeordnete)
        end

        it 'puts person in foreign group for more than 4 digits' do
          person.update(zip_code: 90210)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
        end

        it 'puts person in foreign group for less than 4 digits' do
          person.update(zip_code: 210)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
        end
      end
    end
  end

  describe 'Medien_und_dritte' do
    let(:role)           {  'Medien_und_dritte' }

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
      before { update_email_and_zip_codes }

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

      context :foreign_zip_code do
        before { create_foreign_subtree }

        it 'puts person in bern group for matching zip' do
          person.update(zip_code: 3000)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
          expect(new_role.group).to eq groups(:bern_kontakte)
        end

        it 'puts person in foreign group for more than 4 digits' do
          person.update(zip_code: 90210)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
        end

        it 'puts person in foreign group for less than 4 digits' do
          person.update(zip_code: 210)
          SortingHat.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
        end
      end
    end
  end

end
