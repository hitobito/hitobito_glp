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
      <div class='form-wrapper'>
        <p id='hitobito-external-form-message'></p>
        <form action='#{@url}' method='post'>
          <fieldset>
            <div class='form-row'>
              <label for='first_name'>
                #{t("activerecord.attributes.person.first_name")} *
              </label>
              <input name='externally_submitted_person[first_name]' type='text' id='first_name'/>
            </div>
            <div class='form-row'>
              <label for='last_name'>
                #{t("activerecord.attributes.person.last_name")} *
              </label>
              <input name='externally_submitted_person[last_name]' type='text' id='last_name'/>
            </div>
            <div class='form-row'>
              <label for='email'>
                #{t("activerecord.attributes.additional_email.email")} *
              </label>
              <input name='externally_submitted_person[email]' type='email' id='email'/>
            </div>
            <div class='form-row'>
              <label for='zip_code'>
                #{t("activerecord.attributes.person.zip_code")} *
              </label>
              <input name='externally_submitted_person[zip_code]' type='text' id='zip_code'/>
            </div>
            <label for='terms_and_conditions'>
              <input name='terms_and_conditions' id='terms_and_conditions' type='checkbox' />
              <a href='#{t("external_form_js.terms_and_conditions_link")}' target='_blank'>#{t("external_form_js.terms_and_conditions_checkbox")}</a>
            </label>
            <div class='button-wrapper'>
              <input type='hidden' name='externally_submitted_person[role]' value='#{role}'/>
              <div class='g-recaptcha' data-sitekey='6LcBNGoUAAAAAO3PJDEgWoN9f0zFFag1WdBRHjYO'></div>
              <input type='submit' value='Abschicken'/>
            </div>
        </form>
      </div>
    END
  end

end
