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
