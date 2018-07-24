require 'spec_helper'

describe ExternallySubmittedPeopleController do

  let!(:group) { groups(:root_zugeordnete) }

  context "POST #create" do
    it "creates a person and saves his/her attributes." do
      expect do
        post :create, externally_submitted_person: {zip_code: "3012",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "mitglied"}, format: :js
      end.to change{Person.count}.by(1)
      expect(Person.last.email).to eq "sauron@evil.com"
      expect(Person.last.first_name).to eq "Sauron"
      expect(Person.last.last_name).to eq "The Abominable"
    end

    it "creates a 'mitglied' role for the new person." do
      post :create, externally_submitted_person: {zip_code: "3012",
                                                  email: "sauron@evil.com",
                                                  first_name: "Sauron",
                                                  last_name: "The Abominable",
                                                  role: "mitglied"}, format: :js
      expect(Role.last.type).to eq "Group::RootZugeordnete::Mitglied"
    end

    it "creates a 'sympathisant' role for the new person." do
      post :create, externally_submitted_person: {zip_code: "3012",
                                                  email: "sauron@evil.com",
                                                  first_name: "Sauron",
                                                  last_name: "The Abominable",
                                                  role: "sympathisant"}, format: :js
      expect(Role.last.type).to eq "Group::RootZugeordnete::Sympathisant"
    end

    it "creates a 'adressverwaltung' role for the new person." do
      post :create, externally_submitted_person: {zip_code: "3012",
                                                  email: "sauron@evil.com",
                                                  first_name: "Sauron",
                                                  last_name: "The Abominable",
                                                  role: "adressverwaltung"}, format: :js
      expect(Role.last.type).to eq "Group::RootZugeordnete::Adressverwaltung"
    end

    it "puts the newly created person in the proper group." do
      post :create, externally_submitted_person: {zip_code: "3012",
                                                  email: "sauron@evil.com",
                                                  first_name: "Sauron",
                                                  last_name: "The Abominable",
                                                  role: "adressverwaltung"}, format: :js
      expect(Person.last.groups.pluck(:type)).to include "Group::RootZugeordnete"
    end
  end
end
