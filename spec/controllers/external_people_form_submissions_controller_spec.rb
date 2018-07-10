require 'spec_helper'

describe ExternalPeopleFormSubmissionsController do
  let(:group) { groups(:kontakte) }

  context "POST #create" do
    it "creates a 'Mitglied'." do
      expect do
        post :create, zip_code: "917 01", email: "sauron@evil.com", role: "mitglied"
      end.to change{Person.count}.by(1)
    end
  end
end
