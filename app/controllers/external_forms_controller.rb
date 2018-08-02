class ExternalFormsController < ApplicationController
  skip_authorization_check

  def index
    @url = Rails.env.production? ? "https://glp.puzzle.ch/de/externally_submitted_people" : "http://localhost:3000/externally_submitted_people"
  end
end
