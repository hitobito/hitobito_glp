class ExternalFormsController < ApplicationController
  skip_authorization_check
  skip_before_filter :verify_authenticity_token, :only => [:loader]
  before_action :set_url, :only => [:index, :loader]

  def index
  end

  def loader
    @form = external_form({
      :role => params[:role] || "mitglied",
      :language => params[:language] || "de"
    })
  end

  private

  def set_url
    @url = Rails.env.production? ? "https://glp.puzzle.ch/de/externally_submitted_people" : "http://localhost:3000/externally_submitted_people"
  end

  def external_form(options)
    role = options[:role]
    I18n.locale = options[:language]

    <<-END
      <form action='#{@url}' method='post'>
        <label for='first_name'>
          #{t("activerecord.attributes.person.first_name")}: <input name='externally_submitted_person[first_name]' type='text' id='first_name'/>
        </label>
        <label for='last_name'>
          #{t("activerecord.attributes.person.last_name")}: <input name='externally_submitted_person[last_name]' type='text' id='last_name'/>
        </label>
        <label for='email'>
          #{t("activerecord.attributes.additional_email.email")}: <input name='externally_submitted_person[email]' type='email' id='email'/>
        </label>
        <label for='zip_code'>
          #{t("activerecord.attributes.person.zip_code")}: <input name='externally_submitted_person[zip_code]' type='text' id='zip_code'/>
        </label>
        <input type='hidden' name='externally_submitted_person[role]' value='#{role}'/>
        <input type='submit' value='Abschicken'/>
      </form>
    END
  end

end
