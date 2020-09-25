# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require 'spec_helper'

describe SortingHat::Finder do
  let(:root)   { groups(:root) }
  let(:bern)   { groups(:bern) }
  let(:finder) { SortingHat::Finder.new(role, zip, jglp) }
  subject { finder.groups }


  def create_foreign_subtree
    @foreign = Group::Kanton.create!(name: 'Ausland', parent: root, zip_codes: SortingHat::FOREIGN_ZIP_CODE)
    @foreign_kontakte = Group::KantonKontakte.create!(name: 'Ausland Kontakte', parent: @foreign)
    @foreign_zugeordnete = Group::KantonZugeordnete.create!(name: 'Ausland Zugeordnete', parent: @foreign)
  end

  def create_jglp_subtree
    @jglp = Group::Kanton.create!(name: 'jGLP', parent: root, zip_codes: SortingHat::JGLP_ZIP_CODE)
    @jglp_kontakte = Group::KantonKontakte.create!(name: 'jGLP Kontakte', parent: @jglp)
    @jglp_zugeordnete = Group::KantonZugeordnete.create!(name: 'jGLP Zugeordnete', parent: @jglp)
  end

  def create_jglp_be_subtree(zip_codes)
    @jglp_be = Group::Bezirk.create!(name: 'jGLP be', parent: @jglp, zip_codes: zip_codes)
    @jglp_be_kontakte = Group::BezirkKontakte.create!(name: 'jGLP be Kontakte', parent: @jglp_be)
    @jglp_be_zugeordnete = Group::BezirkZugeordnete.create!(name: 'jGLP be Zugeordnete', parent: @jglp_be)
  end

  %w(Mitglied Sympathisant Medien_und_dritte).zip(%w(zugeordnete zugeordnete kontakte)).each do |role_type, group_type|
    describe role_type do
      let(:role)  { role_type }
      let(:jglp)  { false }
      let(:zip)   { 3000 }

      it "is root_#{group_type}" do
        expect(subject).to eq [groups(:"root_#{group_type}")]
      end

      it "is bern_#{group_type} if zip matches" do
        groups(:bern).update(zip_codes: zip)
        expect(subject).to eq [groups(:"bern_#{group_type}")]
      end

      it "is root_#{group_type} if multiple zips match" do
        groups(:bern).update(zip_codes: zip)
        groups(:zurich).update(zip_codes: zip)
        expect(subject).to eq [groups(:"root_#{group_type}")]
      end

      it "is root_#{group_type} if zip matches and multiple matching types exist" do
        groups(:bern).update(zip_codes: zip)
        groups(:bern).children.create!(type: "Group::Kanton#{group_type.camelcase}", name: 'dummy')
        expect(subject).to eq [groups(:"root_#{group_type}")]
      end

      it "is bern_#{group_type} if multiple zips match and one is deleted" do
        groups(:bern).update(zip_codes: zip)
        groups(:zurich).update(zip_codes: zip, deleted_at: Time.zone.now)
        expect(subject).to eq [groups(:"bern_#{group_type}")]
      end

      it "is bern_#{group_type} if zip matches and multiple matching types exist but one is deleted " do
        groups(:bern).update(zip_codes: zip)
        groups(:bern).children.create!(type: "Group::Kanton#{group_type.camelcase}", name: 'dummy', deleted_at: Time.zone.now)
        expect(subject).to eq [groups(:"bern_#{group_type}")]
      end

      describe 'without zip' do
        let(:zip) { nil }

        it "is root_#{group_type}" do
          expect(subject).to eq [groups(:"root_#{group_type}")]
        end
      end
    end
  end

  describe 'jglp'  do
    let(:jglp)  { true }
    let(:zip)  { 3000 }
    let(:role) { 'Mitglied' }

    it 'is jglp_zugeordnete' do
      create_jglp_subtree
      expect(subject).to eq [@jglp_zugeordnete]
    end

    it 'is jglp_be_zugeordnete' do
      create_jglp_subtree
      create_jglp_be_subtree(zip)
      expect(subject).to eq [@jglp_be_zugeordnete]
    end

    it 'is jglp_zugeordnete and bern_zugeordnete' do
      create_jglp_subtree
      groups(:bern).update(zip_codes: zip)
      expect(subject).to match_array [groups(:bern_zugeordnete), @jglp_zugeordnete]
    end

    it 'is bern_zugeordnete and jglp_be_zugeordnete' do
      create_jglp_subtree
      create_jglp_be_subtree(zip)
      groups(:bern).update(zip_codes: zip)

      expect(subject).to match_array [groups(:bern_zugeordnete), @jglp_be_zugeordnete]
    end

    describe 'jglp false' do
      let(:jglp) { false }
      let(:role) { 'Mitglied' }

      it 'only creates outside of jglp tree' do
        create_jglp_subtree
        create_jglp_be_subtree(zip)
        groups(:bern).update(zip_codes: zip)
        expect(subject).to match_array [groups(:bern_zugeordnete)]
      end
    end
  end

  describe 'foreign'  do
    let(:zip)      { 90210 }
    let(:jglp)     { true }
    let(:role)     { 'Mitglied' }

    it 'is root_zugeordnete' do
      expect(subject).to eq [groups(:root_zugeordnete)]
    end

    it 'is foreign_zugeordnete' do
      create_foreign_subtree
      expect(subject).to eq [@foreign_zugeordnete]
    end
  end
end
