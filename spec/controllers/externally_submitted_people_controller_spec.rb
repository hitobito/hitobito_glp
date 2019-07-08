# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe ExternallySubmittedPeopleController do
  let(:root_zugeordnete)   { groups(:root_zugeordnete) }
  let(:root_kontakte)      { groups(:root_kontakte) }

  let(:bern_zugeordnete)   { groups(:bern_zugeordnete) }
  let(:bern_kontakte)      { groups(:bern_kontakte) }

  let(:zurich_zugeordnete) { groups(:zurich_zugeordnete) }
  let(:zurich_kontakte)    { groups(:zurich_kontakte) }

  def subject_with_args args={}
    post :create, externally_submitted_person: {zip_code: "9171",
                                                email: "sauron@evil.com",
                                                first_name: "Sauron",
                                                last_name: "The Abominable",
                                                preferred_language: "de",
                                                role: "mitglied"}.merge(args), format: :js
  end

  it "creates a person and saves his/her attributes." do
    expect{subject_with_args}.to change{Person.count}.by(1)
    expect(Person.last.email).to eq "sauron@evil.com"
    expect(Person.last.first_name).to eq "Sauron"
    expect(Person.last.last_name).to eq "The Abominable"
    expect(Person.last.zip_code).to eq "9171"
    expect(Person.last.preferred_language).to eq "de"
  end

  it "sends 3 notification emails to." do
    expect{subject_with_args}.to change(ActionMailer::Base.deliveries, :count).by(3)
  end

  context "when submitted zip code DOES match existing layer groups' zip_codes" do
    context "it places him in respective subgroups" do

      it "when submitted role is a mitglied." do
        subject_with_args
        expect(Person.last.groups).to include bern_zugeordnete
      end

      it "when submitted role is a symphatisant." do
        subject_with_args({role: "sympathisant"})
        expect(Person.last.groups).to include bern_zugeordnete
      end

      it "when submitted role is a medien und dritte." do
        subject_with_args({role: "medien_und_dritte"})
        expect(Person.last.groups).to include bern_kontakte
      end
    end
  end

  context "when submitted zip code DOES NOT match any existing layer groups' zip_codes" do
    context "it places him in one of root groups equivalents" do

      it "when submitted role is a mitglied." do
        subject_with_args({zip_code: "1234"})
        expect(Person.last.groups).to include root_zugeordnete
      end

      it "when submitted role is a symphatisant." do
        subject_with_args({zip_code: "1234", role: "sympathisant"})
        expect(Person.last.groups).to include root_zugeordnete
      end

      it "when submitted role is a medien und dritte." do
        subject_with_args({zip_code: "1234", role: "medien_und_dritte"})
        expect(Person.last.groups).to include root_kontakte
      end

    end
  end

  context 'zip_code' do
    it 'accepts any string as zip_code' do
      subject_with_args({zip_code: "asdf", role: "medien_und_dritte"})
      expect(Person.last.groups).to include root_kontakte
    end
  end

  context 'preferred_language' do
    it 'defaults to german when value is blank' do
      subject_with_args({role: "medien_und_dritte", preferred_language: ''})
      expect(Person.last.preferred_language).to eq 'de'
    end

    it 'defaults to german when value is not send' do
      subject_with_args({role: "medien_und_dritte"})
      expect(Person.last.preferred_language).to eq 'de'
    end
  end

  context "fails gracefully" do

    it "when submitted email is a duplicate." do
      subject_with_args
      subject_with_args
      error = JSON.parse(response.body)['error']
      expect(error).to start_with 'Deine E-Mail-Adresse ist leider schon vergeben'
    end

  end

end
