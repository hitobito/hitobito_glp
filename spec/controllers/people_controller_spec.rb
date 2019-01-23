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

  it 'notifies the layer group and the root group when a mitlied is deleted.' do
    expect do
      delete :destroy, group_id: role.person.primary_group.id, id: role.person.id
    end.to change(ActionMailer::Base.deliveries, :count).by(2)
  end

  it 'notifies schweiz@grunliberale.ch whenever a person changes his/her PLZ.' do
    expect do
      put :update, group_id: role.person.primary_group.id, id: role.person.id, person: { zip_code: "4321" }
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
