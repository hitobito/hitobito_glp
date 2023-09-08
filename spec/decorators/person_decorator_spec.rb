# frozen_string_literal: true

#  Copyright (c) 2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require 'spec_helper'

describe PersonDecorator do
  let(:root) { groups(:root) }
  let(:admin) { people(:admin) }
  let(:person) { Fabricate(Group::Root::Administrator.name, group: root).person }
  let(:spender) { Fabricate(Group::Spender.name, parent: groups(:bern)) }
  let(:decorator) { PersonDecorator.new(person) }

  before do
    @spender_role = Fabricate(Group::Spender::Spender.name, group: spender, person: person)
    sign_in(admin)
  end

  describe 'roles_grouped' do

    subject { decorator.roles_grouped }

    context :admin do
      it 'includes root but not spender group' do
        expect(subject).to have_key(root)
        expect(subject).not_to have_key(spender)
      end

      it 'includes no Spender role' do
        expect(subject[spender]).to be_nil
      end
    end

    context :spendenverwalter do
      before do
        Fabricate(Group::Kanton::Spendenverwalter.name, group: groups(:bern), person: admin)
      end

      it 'includes root and spender group' do
        expect(subject).to have_key(root)
        expect(subject).to have_key(spender)
      end

      it 'includes spender role for spender group' do
        expect(subject[spender]).to eq [@spender_role]
      end
    end

    context :root_spendenverwalter do
      let(:root_spender) { Fabricate(Group::Spender.name, parent: root) }
      let(:person) { Fabricate(Group::Root::Spendenverwalter.name, group: root).person }

      it 'includes root but not spender group' do
        expect(subject).to have_key(root)
        expect(subject).not_to have_key(spender)
      end
    end
  end


  describe 'filtered_roles of other person in spender group' do
    subject(:filtered_roles) { decorator.filtered_roles(spender) }

    it 'is empty when admin has no spendenverwalter role' do
      expect(filtered_roles).to eq []
    end

    it 'is present when admin has spendenverwalter role in group' do
      Fabricate(Group::Root::Spendenverwalter.name, group: root, person: admin)
      expect(filtered_roles).to eq [@spender_role]
    end
  end
end
