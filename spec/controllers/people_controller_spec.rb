require 'spec_helper'

describe PeopleController, type: :controller do
  let!(:group) { groups(:root_zugeordnete) }
  let!(:role) { roles(:mitglied) }
  let!(:member) { role.person }
  let(:admin) { people(:leader) }

  before { sign_in(admin) }

  it 'deletes person' do
    expect do
      delete :destroy, group_id: role.person.primary_group.id, id: role.person.id
    end.to change(ActionMailer::Base.deliveries, :count).by(2)
  end
end
