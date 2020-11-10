# frozen_string_literal: true

#  Copyright (c) 2020, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe 'Login', type: :request do

  subject { page }

  let(:admin) do 
    p = Fabricate('Group::Root::Administrator', group: groups(:root)).person
    p.update!(password: 'hito42bito')
    p.phone_numbers.create!(number: '+41 77 222 78 90', label: 'Mobil')
    p
  end

  before do
    stub_request(:post, /api.twilio.com/).
      with(
        body: {"Body"=>/[0-9]+ ist dein 2FA-Code für glp community/, "From"=>"glp", "To"=>"+41772227890"})
        .to_return(status: 200, body: "", headers: {})
  end

  context 'with 2FA' do
    it 'requires second factor for admin user' do
      login

      code = admin.reload.second_factor_code
      post users_two_factor_authentication_confirmation_path(person: { second_factor_code: code })
      expect(response).to redirect_to(root_path)
      expect(session[:two_fa_person_id]).to be_nil
    end

    it 'is not possible to use the application when second factor auth is pending' do
      login

      get group_person_path(group_id: admin.primary_group.id, id: admin.id)
      expect(response).to redirect_to(new_person_session_path)
      expect(session[:two_fa_person_id]).to be_nil
    end

    it 'displays error if second factor code is wrong' do
      login

      post users_two_factor_authentication_confirmation_path(person: { second_factor_code: '4242424242424242' })
      expect(response).to redirect_to(users_two_factor_authentication_confirmation_path)

      expect(flash[:alert]).to eq('2FA-Code falsch oder abgelaufen, bitte versuche es erneut')
      expect(session[:two_fa_person_id]).to eq(admin.id)
    end

    it 'is not possible to login if too many failed 2FA attempts' do
      admin.update!(
        second_factor_generated_at: Time.zone.today,
        second_factor_unsuccessful_tries: 5)

      post person_session_path, params: { person: { email: admin.email, password: 'hito42bito' } }

      expect(response).to redirect_to('/')

      expect(flash[:alert]).to eq('Zu viele falsche 2FA-Codes, bitte versuche es morgen wieder')
      expect(session[:two_fa_person_id]).to be_nil
    end

    it 'is not possible to login if sms service not reachable' do
      stub_request(:post, /api.twilio.com/).
        with(
          body: {"Body"=>/[0-9]+ ist dein 2FA-Code für glp community/, "From"=>"glp", "To"=>"+41772227890"})
        .to_raise(StandardError)

      post person_session_path, params: { person: { email: admin.email, password: 'hito42bito' } }

      expect(response).to redirect_to('/')

      expect(flash[:alert]).to eq('Die Zustellung des 2FA-Codes hat nicht geklappt, bitte kontaktiere das Generalsekretariat')
      expect(session[:two_fa_person_id]).to be_nil
    end
  end

  private

  def login
    expect(admin.two_factor_authentication_required?).to eq(true)

    get '/'
    expect(response).to redirect_to(new_person_session_path)
    follow_redirect!

    expect(response.status).to eq 200

    post person_session_path, params: { person: { email: admin.email, password: 'hito42bito' } }

    expect(response).to redirect_to(users_two_factor_authentication_confirmation_path)
    follow_redirect!

    # make sure user is not logged in yet
    expect(assigns(:current_user)).to be_nil
    expect(assigns(:current_person)).to be_nil

    expect(session[:two_fa_person_id]).to eq(admin.id)
  end

end
