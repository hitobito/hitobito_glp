# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe PeopleController, type: :controller do
  let!(:group) { groups(:root_zugeordnete) }
  let!(:role) { roles(:mitglied) }
  let!(:member) { role.person }
  let(:admin) { people(:leader) }

  before :each do
    sign_in(admin)
  end

  include ActiveJob::TestHelper

  it 'notifies the layer group and the root group when a mitlied is deleted.' do
    perform_enqueued_jobs do
      expect do
        delete :destroy, params: { group_id: role.person.primary_group.id, id: role.person.id }
      end.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end

  it 'notifies schweiz@grunliberale.ch whenever a person changes his/her PLZ.' do
    perform_enqueued_jobs do
      expect do
        put :update, params: { group_id: role.person.primary_group.id, id: role.person.id, person: { zip_code: "4321" } }
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  context 'simplfied_view' do
    render_views

    let(:group)  { groups(:root_kontakte) }
    let(:person) { Fabricate(:person) }

    before do
      Group::RootKontakte::Kontakt.create!(group: group, person: person)
      sign_in(person)
    end

    it 'does not render main_nav when view is simplified' do
      get :show, params: { group_id: group.id, id: person.id }
      dom = Capybara::Node::Simple.new(response.body)
      expect(dom).not_to have_text 'Gruppen'
      expect(dom).not_to have_text 'Personen'
    end
  end
end
