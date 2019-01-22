require 'spec_helper'

describe Devise::SessionsController do

  before { request.env['devise.mapping'] = Devise.mappings[:person] }

  it 'attempts to 2FA auth for root admin' do
    person = people(:admin)
    person.update(password: 'foobar')
    post :create, person: { email: person.email, password: 'foobar' }
    expect(flash[:alert]).to match(/Zustellung des 2FA-Codes hat nicht geklappt/)
  end

  it 'attempts to 2FA auth for kanton admin' do
    person = Fabricate(Group::Kanton::Administrator.name.to_sym, group: groups(:bern)).person
    person.update(password: 'foobar')
    post :create, person: { email: person.email, password: 'foobar' }
    expect(flash[:alert]).to match(/Zustellung des 2FA-Codes hat nicht geklappt/)
  end

  it 'does not attempts to 2FA auth for mitglied' do
    person = people(:mitglied)
    person.update(password: 'foobar')
    post :create, person: { email: person.email, password: 'foobar' }
    expect(flash[:alert]).not_to be_present
    expect(controller.send(:current_person)).to be_present
  end

end
