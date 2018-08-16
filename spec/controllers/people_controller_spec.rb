require 'spec_helper'

describe PeopleController, type: :controller do
  let(:member) { people(:member) }
  let(:admin) { people(:admin) }

  before { sign_in(admin) }

  it 'deletes person' do
    expect do
      delete :destroy, group_id: member.primary_group.id, id: member.id
    end.to change(Person, :count).by(-1)
  end

  # it "sends an email" do
  # delete :destroy, group_id: member.primary_group.id, id: member.id

  # is_expected.to change(ActionMailer::Base.deliveries, :count).by(1)
  #   expect do
  #   end.to change(ActionMailer::Base.deliveries, :count).by(1)
  # end
end
