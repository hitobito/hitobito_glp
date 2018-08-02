require 'spec_helper'

describe ExternallySubmittedPeopleController do

  let!(:root_zugeordnete_group) { groups(:root_zugeordnete) }
  let!(:root_kontakte_group) { groups(:root_kontakte) }

  let!(:kanton) { groups(:kanton) }
  let!(:kanton_zugeordnete_group) { groups(:kanton_zugeordnete) }
  let!(:another_kanton_zugeordnete_group) { groups(:another_kanton_zugeordnete) }
  let!(:kanton_kontakte_group) { groups(:kanton_kontakte) }
  let!(:another_kanton_kontakte_group) { groups(:another_kanton_kontakte) }

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

  context "when submitted zip code DOES match existing layer groups' zip_codes" do
    context "it places him in respective subgroups." do
      it "when submitted role is a mitglied." do
        post :create, externally_submitted_person: {zip_code: "917 01",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "mitglied"}, format: :js
        expect(Person.last.groups).to include kanton_zugeordnete_group, another_kanton_zugeordnete_group
      end
      it "when submitted role is a symphatisant" do
        post :create, externally_submitted_person: {zip_code: "917 01",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "sympathisant"}, format: :js
        expect(Person.last.groups).to include kanton_zugeordnete_group, another_kanton_zugeordnete_group
      end
      it "when submitted role is a adressverwaltung" do
        post :create, externally_submitted_person: {zip_code: "917 01",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "adressverwaltung"}, format: :js
        expect(Person.last.groups).to include kanton_kontakte_group, another_kanton_kontakte_group
      end
    end
  end

  context "when submitted zip code DOES NOT match any existing layer groups' zip_codes" do
    context "it places him in one of root groups equivalents" do
      it "when submitted role is a mitglied" do
        post :create, externally_submitted_person: {zip_code: "12345",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "mitglied"}, format: :js
        expect(Person.last.groups).to include root_zugeordnete_group
      end
      it "when submitted role is a symphatisant" do
        post :create, externally_submitted_person: {zip_code: "12345",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "sympathisant"}, format: :js
        expect(Person.last.groups).to include root_zugeordnete_group
      end
      it "when submitted role is a adressverwaltung" do
        post :create, externally_submitted_person: {zip_code: "12345",
                                                    email: "sauron@evil.com",
                                                    first_name: "Sauron",
                                                    last_name: "The Abominable",
                                                    role: "adressverwaltung"}, format: :js
        expect(Person.last.groups).to include root_kontakte_group
      end
    end
  end

end
