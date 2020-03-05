# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe ExternalFormsController do
  context "GET #index" do
    it "gets index without any errors." do
      get :index
    end
  end

  context 'GET #loader' do
    render_views
    it "renders without any errors." do
      get :loader, format: :js
      expect(response.body).to match (%r{action=.*de/externally_submitted_people})
    end

    it "uses passed language for locale in form action" do
      get :loader, params: { language: :it }, format: :js
      expect(response.body).to match (%r{action=.*it/externally_submitted_people})
    end
  end
end
