# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


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
