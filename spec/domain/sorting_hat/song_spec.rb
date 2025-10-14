#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe SortingHat::Song do
  let(:person) { Fabricate(:person) }
  let(:root) { groups(:root) }
  let(:bern) { groups(:bern) }

  let(:foreign_zip_code) { SortingHat::FOREIGN_ZIP_CODE }
  let(:jglp_zip_code) { SortingHat::JGLP_ZIP_CODE }
  let(:jglp) { false }

  let(:notifier) { @notifier }
  let(:new_role) { person.roles.last }

  before do
    @notifier = stub_const("NotifierMailer", double("notifier").as_null_object)
  end

  def update_email_and_zip_codes
    bern.update(zip_codes: "3000,3001", email: "be@example.com")
  end

  def create_foreign_subtree
    @foreign = Group::Kanton.create!(name: "Ausland", parent: root, zip_codes: foreign_zip_code)
    @foreign_kontakte = Group::KantonKontakte.create!(name: "Kontakte", parent: @foreign)
    @foreign_zugeordnete = Group::KantonZugeordnete.create!(name: "Zugeordnete", parent: @foreign)
  end

  def create_jglp_subtree
    @jglp = Group::Kanton.create!(name: "jGLP", parent: root, zip_codes: jglp_zip_code,
      email: "jglp@example.com")
    @jglp_kontakte = Group::KantonKontakte.create!(name: "Kontakte", parent: @jglp)
    @jglp_zugeordnete = Group::KantonZugeordnete.create!(name: "Zugeordnete", parent: @jglp)
  end

  def create_jglp_be_subtree
    @jglp_be = Group::Bezirk.create!(name: "be", parent: @jglp, zip_codes: "3010",
      email: "jglp_be@example.com")
    @jglp_be_kontakte = Group::BezirkKontakte.create!(name: "Kontakte", parent: @jglp_be)
    @jglp_be_zugeordnete = Group::BezirkZugeordnete.create!(name: "Zugeordnete", parent: @jglp_be)
  end

  it "raises on invalid role" do
    expect do
      SortingHat::Song.new(person, "Admin", jglp).sing
    end.to raise_exception(ArgumentError)
  end

  describe "Mitglied" do
    let(:role) { "Mitglied" }

    it "notifies person and monitoring email address" do
      expect(notifier).to receive(:welcome_mitglied).with(person, "de")
      expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
        role,
        SortingHat::MONITORING_EMAIL,
        jglp)
      SortingHat::Song.new(person, role, jglp).sing
    end

    it "notifies person in preferred_language" do
      person.update!(preferred_language: "fr")
      expect(notifier).to receive(:welcome_mitglied).with(person, "fr")
      SortingHat::Song.new(person.reload, role, jglp).sing
    end

    context :jglp do
      let(:jglp) { true }

      it "puts person in top level jglp group" do
        create_jglp_subtree
        expect(notifier).to receive(:mitglied_joined).with(person, "jglp@example.com", jglp)

        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        expect(new_role.group).to eq @jglp_zugeordnete
      end

      it "falls back to root group if top level jglp group is missing" do
        expect(notifier).to receive(:mitglied_joined).with(person, "root@example.net", jglp)

        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end
    end

    context :zip_code do
      before { update_email_and_zip_codes }

      it "puts person in Kanton with matching zip" do
        person.update(zip_code: 3000)
        expect(notifier).to receive(:mitglied_joined).with(person, "be@example.com", jglp)
        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:bern_zugeordnete)
      end

      it "puts person in Bezirk with matching zip" do
        person.update(zip_code: 3002)
        bezirk = Fabricate(Group::Bezirk.sti_name, parent: groups(:bern), zip_codes: "3002",
          email: "bezirk@example.com")
        bezirk_zugeordnete = Fabricate(Group::BezirkZugeordnete.sti_name, parent: bezirk)
        expect(notifier).to receive(:mitglied_joined).with(person, "bezirk@example.com", jglp)
        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::BezirkZugeordnete::Mitglied)
        expect(new_role.group).to eq bezirk_zugeordnete
      end

      it "notifies admins of kanton and root group" do
        person.update(zip_code: 3000)
        kantons_admin = Fabricate(Group::Kanton::Administrator.sti_name,
          group: groups(:bern)).person

        [kantons_admin, people(:leader), people(:admin)].each do |admin|
          expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
            role,
            admin.email,
            jglp)
        end
        SortingHat::Song.new(person, role, jglp).sing
      end

      it "does not notify admins if they set notify_on_join to false" do
        person.update(zip_code: 3000)
        Person.update_all(notify_on_join: false)

        [people(:leader), people(:admin)].each do |admin|
          expect(notifier).not_to receive(:mitglied_joined_monitoring).with(person,
            role,
            admin.email,
            jglp)
        end
        SortingHat::Song.new(person, role, jglp).sing
      end

      it "puts person in root group if multiple zips match" do
        groups(:zurich).update(zip_codes: "3000")
        person.update(zip_code: 3000)
        expect(notifier).to receive(:mitglied_joined).with(person, "root@example.net", jglp)

        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end

      it "puts person in root group" do
        expect(notifier).to receive(:mitglied_joined).with(person, "root@example.net", jglp)

        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Mitglied)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end

      context :jglp do
        let(:jglp) { true }

        before do
          create_jglp_subtree
          create_jglp_be_subtree
        end

        it "puts person in jglp Bezirk with matching zip" do
          person.update(zip_code: 3010)
          expect(notifier).to receive(:mitglied_joined).with(person, "jglp_be@example.com", jglp)

          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::BezirkZugeordnete::Mitglied)
          expect(new_role.group).to eq @jglp_be_zugeordnete
        end

        it "puts person in jglp Bezirk and Kanton with matching zip" do
          person.update(zip_code: 3010)
          groups(:bern).update(zip_codes: 3010)
          expect(notifier).to receive(:mitglied_joined).with(person, "jglp_be@example.com", jglp)

          SortingHat::Song.new(person, role, jglp).sing
          expect(person).to have(2).roles
          expect(groups(:bern_zugeordnete).people).to eq [person]
          expect(@jglp_be_zugeordnete.people).to eq [person]
        end

        it "puts person only in jglp Bezirk if two groups in Kantons subtree match" do
          person.update(zip_code: 3010)
          groups(:bern).update(zip_codes: 3010)
          groups(:zurich).update(zip_codes: 3010)
          expect(notifier).to receive(:mitglied_joined).with(person, "jglp_be@example.com", jglp)

          SortingHat::Song.new(person, role, jglp).sing
          expect(person).to have(1).roles
          expect(@jglp_be_zugeordnete.people).to eq [person]
        end

        it "puts person only in toplevel jglp only two groups in Kantons subtree match" do
          person.update(zip_code: 3004)
          groups(:bern).update(zip_codes: 3004)
          groups(:zurich).update(zip_codes: 3004)
          expect(notifier).to receive(:mitglied_joined).with(person, "jglp@example.com", jglp)

          SortingHat::Song.new(person, role, jglp).sing
          expect(person).to have(1).roles
          expect(@jglp_zugeordnete.people).to eq [person]
        end

        it "puts person top level jglp group without matching zip" do
          person.update(zip_code: 3004)
          expect(notifier).to receive(:mitglied_joined).with(person, "jglp@example.com", jglp)

          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
          expect(new_role.group).to eq @jglp_zugeordnete
        end

        it "puts person top level jglp group with foreign zip" do
          person.update(zip_code: 90210)
          expect(notifier).to receive(:mitglied_joined).with(person, "jglp@example.com", jglp)

          SortingHat::Song.new(person, role, jglp).sing
          expect(person).to have(1).role
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
          expect(new_role.group).to eq @jglp_zugeordnete
        end
      end

      context :foreign_zip_code do
        before { create_foreign_subtree }

        it "puts person in bern group for matching zip" do
          person.update(zip_code: 3000)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
          expect(new_role.group).to eq groups(:bern_zugeordnete)
        end

        it "puts person in foreign group for more than 4 digits" do
          person.update(zip_code: 90210)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        end

        it "puts person in foreign group for less than 4 digits" do
          person.update(zip_code: 210)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Mitglied)
        end
      end
    end
  end

  describe "Sympathisant" do
    let(:role) { "Sympathisant" }

    it "notifies person and monitoring email address" do
      expect(notifier).to receive(:welcome_sympathisant).with(person, "de")
      expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
        role,
        SortingHat::MONITORING_EMAIL,
        jglp)
      SortingHat::Song.new(person, role, jglp).sing
    end

    it "notifies person in preferred_language" do
      person.update!(preferred_language: "fr")
      expect(notifier).to receive(:welcome_sympathisant).with(person, "fr")
      SortingHat::Song.new(person.reload, role, jglp).sing
    end

    context :zip_code do
      before { update_email_and_zip_codes }

      it "puts person in Kanton with matching zip" do
        person.update(zip_code: 3000)
        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
        expect(new_role.group).to eq groups(:bern_zugeordnete)
      end

      it "puts person in root group" do
        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootZugeordnete::Sympathisant)
        expect(new_role.group).to eq groups(:root_zugeordnete)
      end

      context :foreign_zip_code do
        before { create_foreign_subtree }

        it "puts person in bern group for matching zip" do
          person.update(zip_code: 3000)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
          expect(new_role.group).to eq groups(:bern_zugeordnete)
        end

        it "puts person in foreign group for more than 4 digits" do
          person.update(zip_code: 90210)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
        end

        it "puts person in foreign group for less than 4 digits" do
          person.update(zip_code: 210)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonZugeordnete::Sympathisant)
        end
      end
    end
  end

  describe "Medien_und_dritte" do
    let(:role) { "Medien_und_dritte" }

    it "notifies person and monitoring email address" do
      expect(notifier).to receive(:welcome_medien_und_dritte).with(person, "de")
      expect(notifier).to receive(:mitglied_joined_monitoring).with(person,
        role,
        SortingHat::MONITORING_EMAIL,
        jglp)
      SortingHat::Song.new(person, role, jglp).sing
    end

    it "notifies person in preferred_language" do
      person.update!(preferred_language: "fr")
      expect(notifier).to receive(:welcome_medien_und_dritte).with(person, "fr")
      SortingHat::Song.new(person.reload, role, jglp).sing
    end

    context :zip_code do
      before { update_email_and_zip_codes }

      it "puts person in Kanton with matching zip" do
        person.update(zip_code: 3000)
        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
        expect(new_role.group).to eq groups(:bern_kontakte)
      end

      it "puts person in root group" do
        SortingHat::Song.new(person, role, jglp).sing
        expect(new_role).to be_a(Group::RootKontakte::Kontakt)
        expect(new_role.group).to eq groups(:root_kontakte)
      end

      context :foreign_zip_code do
        before { create_foreign_subtree }

        it "puts person in bern group for matching zip" do
          person.update(zip_code: 3000)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
          expect(new_role.group).to eq groups(:bern_kontakte)
        end

        it "puts person in foreign group for more than 4 digits" do
          person.update(zip_code: 90210)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
        end

        it "puts person in foreign group for less than 4 digits" do
          person.update(zip_code: 210)
          SortingHat::Song.new(person, role, jglp).sing
          expect(new_role).to be_a(Group::KantonKontakte::Kontakt)
        end
      end
    end
  end
end
