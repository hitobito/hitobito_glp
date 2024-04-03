# frozen_string_literal: true

#  Copyright (c) 2022-2024, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require 'spec_helper'

describe Role do
  context 'paper_trail', versioning: true do
    let!(:person) { people(:admin) }
    let!(:donor_group) { Fabricate(Group::Spender.to_s, parent: groups(:root)) }
    let!(:donor) { Fabricate(Group::Spender::Spender.to_s, group: donor_group).person }

    before do
      HitobitoGlp::Wagon.configure_paper_trail!
    end

    context 'on non donor role' do
      it 'sets main on create' do
        expect do
          role = Group::Root::Administrator.new
          role.group = groups(:root)
          role.person = person
          role.save!
        end.to change { PaperTrail::Version.count }.by(1)

        version = PaperTrail::Version.order(:created_at, :id).last
        expect(version.event).to eq('create')
        expect(version.main).to eq(person)
      end

      it 'sets main on update' do
        role = person.roles.first
        expect do
          role.update!(label: 'Foo')
        end.to change { PaperTrail::Version.count }.by(1)

        version = PaperTrail::Version.order(:created_at, :id).last
        expect(version.event).to eq('update')
        expect(version.main).to eq(person)
      end

      it 'sets main on destroy' do
        role = person.roles.first
        expect do
          role.really_destroy!
        end.to change { PaperTrail::Version.count }.by(1)

        version = PaperTrail::Version.order(:created_at, :id).last
        expect(version.event).to eq('destroy')
        expect(version.main).to eq(person)
      end
    end

    context 'on donor role' do
      it 'does not set main on create' do
        expect do
          role = Group::Spender::Spender.new
          role.group = donor_group
          role.person = person
          role.save!
        end.to_not change { PaperTrail::Version.count }
      end

      it 'does not set main on update' do
        role = donor.roles.first
        expect do
          role.update!(label: 'Foo')
        end.to_not change { PaperTrail::Version.count }
      end

      it 'does not set main on destroy' do
        role = donor.roles.first
        expect do
          role.really_destroy!
        end.to_not change { PaperTrail::Version.count }
      end
    end
  end
end
