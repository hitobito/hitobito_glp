require 'spec_helper'

describe ExternalFormsController do
  context "GET #index" do
    it "gets index without any errors." do
      get :index
    end
  end
end
