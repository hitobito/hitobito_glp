class ExternalFormsController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_person!
  skip_before_filter :verify_authenticity_token, :only => [:loader]
  before_action :set_url, :only => [:index, :loader]

  def index
  end

  def loader
    @language = params[:language] || "de"
    I18n.locale = @language
    @role = params[:role] || "mitglied"
    @form = external_form({
      :role => @role
    })
  end

  private

  def set_url
    @url = Rails.env.production? ? "https://glp-community.ch/de/externally_submitted_people" : "http://localhost:3000/externally_submitted_people"
  end

  def external_form(options)
    role = options[:role]

    <<-END
      <div class='form'>
        <div class='form-wrapper'>
          <p id='hitobito-external-form-message'></p>
          <form action='#{@url}?locale=#{@language}' method='post'>
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
                  #{t("external_form_js.zip_code")} *
                </label>
                <input name='externally_submitted_person[zip_code]' type='text' id='zip_code'/>
              </div>
              <label for='terms_and_conditions'>
                <input name='terms_and_conditions' id='terms_and_conditions' type='checkbox' />
                #{t("external_form_js.terms_and_conditions_checkbox_html", :link => (
                  view_context.link_to(
                    t("external_form_js.terms_and_conditions_link_text"),
                    t("external_form_js.terms_and_conditions_link"),
                    target: '_blank'
                  ).gsub('"', "'")
                ))}
              </label>
              <input type='hidden' name='externally_submitted_person[role]' value='#{role}'/>
              <input type='hidden' name='externally_submitted_person[preferred_language]' value='#{@language}'/>
              <div class='g-recaptcha' data-sitekey='6LcBNGoUAAAAAO3PJDEgWoN9f0zFFag1WdBRHjYO' data-size='compact'></div>
              <div class='button-wrapper'>
                <input type='submit' value='#{t("global.button.save")}'/>
              </div>
          </form>
        </div>
      </div>
    END
  end

end
