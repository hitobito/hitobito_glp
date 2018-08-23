class ExternalFormsController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_person!
  skip_before_filter :verify_authenticity_token, :only => [:loader]
  before_action :set_url, :only => [:index, :loader]

  def index
  end

  def loader
    @language = params[:language] || "de"
    @role = params[:role] || "mitglied"
    @form = external_form({
      :role => @role
    })
    I18n.locale = @language
  end

  private

  def set_url
    @url = Rails.env.production? ? "https://glp.puzzle.ch/de/externally_submitted_people" : "http://localhost:3000/externally_submitted_people"
  end

  def external_form(options)
    role = options[:role]

    <<-END
      <p id='hitobito-external-form-message'></p>
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
        <label for='terms_and_conditions'>
          <input name='terms_and_conditions' type='checkbox' />
          <a href='#{t("external_form_js.terms_and_conditions_link")}' target='_blank'>#{t("external_form_js.terms_and_conditions_checkbox")}</a>
        </label>
        <input type='hidden' name='externally_submitted_person[role]' value='#{role}'/>
        <input type='submit' value='Abschicken'/>
      </form>
    END
  end

end
