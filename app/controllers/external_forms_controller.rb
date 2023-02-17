# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class ExternalFormsController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_person!
  skip_before_action :verify_authenticity_token, :only => [:loader]

  def index
  end

  def test
    @language = language
    @role = params.fetch(:role, 'mitglied')
    render 'test', layout: false
  end

  def loader
    @language = language
    I18n.locale = @language
    @role = params[:role] || "mitglied"
    @form = external_form({
      :role => @role
    })
  end

  private

  def language
    @language ||= begin
      locale = params.fetch(:language, I18n.default_locale).to_sym
      I18n.available_locales.include?(locale) ? locale : I18n.default_locale
    end.to_s
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def external_form(options)
    action = externally_submitted_people_url(locale: language)
    role = options[:role]

    birthday_pattern = '(0[1-9]|1[0-9]|2[0-9]|3[01]).(0[1-9]|1[012]).[0-9]{4}'
    mitglied = role == 'mitglied'
    sympathisant = role == 'sympathisant'
    mitglied_address_fields = if mitglied
                                [input_field('address', required: true),
                                 input_field('house_number', required: true),
                                 input_field('town', required: true)].join
                              else
                                ''
                              end
    mitglied_additional_fields = if mitglied
                                   [input_field('phone_number'),
                                    gender_field,
                                    input_field('birthday',
                                                type: 'text',
                                                pattern: birthday_pattern,
                                                max: Time.zone.today)].join
                                 else
                                   ''
                                 end
    sympathisant_fields = if sympathisant
                            [["<div id='sympathisant_fields'",
                              "style='max-height: 0; overflow: hidden;",
                              "transition: max-height 0.2s ease-out;'>"].join(' '),
                             input_field('address'),
                             input_field('house_number'),
                             input_field('town'),
                             input_field('phone_number'),
                             gender_field,
                             input_field('birthday',
                                         type: 'text',
                                         pattern: birthday_pattern,
                                         max: Time.zone.today),
                             '</div>',
                             ["<a role='button' href='javascript:void(0)'",
                              "id='sympathisant-fields-collapse-toggle'",
                              "data-show-more='#{t('external_form_js.show_more')}'",
                              "data-show-less='#{t('external_form_js.show_less')}'>",
                              "#{t('external_form_js.show_more')}</a>"].join(' ')].join
                          else
                            ''
                          end
    <<-HTML
      <div class='form'>
        <div class='form-wrapper'>
          <p id='hitobito-external-form-message'></p>
          <form action='#{action}' method='post'>
            <fieldset>
              #{input_field('first_name', required: true)}
              #{input_field('last_name', required: true)}
              #{input_field('email', required: true, type: 'email')}
              #{mitglied_address_fields}
              #{input_field('zip_code', required: mitglied)}
              #{mitglied_additional_fields}
              #{jglp_field(role)}
              #{sympathisant_fields}
              <br/>
              <label for='terms_and_conditions'>
                <input name='terms_and_conditions' id='terms_and_conditions' type='checkbox' required='required' />
                #{t("external_form_js.terms_and_conditions_checkbox_html", :link => (
                  view_context.link_to(
                    t("external_form_js.terms_and_conditions_link_text"),
                    t("external_form_js.terms_and_conditions_link"),
                    target: '_blank'
                  ).gsub('"', "'")
                ))} *
              </label>
              <input type='hidden' name='externally_submitted_person[role]' value='#{role}'/>
              <input type='hidden' name='externally_submitted_person[preferred_language]' value='#{@language}'/>
              <div class='g-recaptcha' required='required' data-sitekey='6LcBNGoUAAAAAO3PJDEgWoN9f0zFFag1WdBRHjYO' data-size='compact'></div>
              <div class='button-wrapper'>
                <input type='submit' value='#{t("external_form_js.submit")}'/>
              </div>
          </form>
        </div>
      </div>
    HTML
  end
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

  def jglp_field(role)
    return '' unless role == 'mitglied'

    <<-HTML
      <label for='jglp'>
        <input name='externally_submitted_person[jglp]' type='checkbox' id='jglp' value='true'/>
        #{t('external_form_js.jglp')}
      </label>
    HTML
  end

  def input_field(key, required: false, type: 'text', max: '', pattern: nil)
    pattern_attr = pattern.nil? ? '' : " pattern='#{pattern}'"
    <<-HTML
      <div class='form-row'>
        <label for='#{key}'>
          #{t("external_form_js.#{key}")} #{required ? '*' : ''}
        </label>
        <input name='externally_submitted_person[#{key}]' #{required ? "required='required'" : ''} type='#{type}' id='#{key}' max='#{max}' #{pattern_attr}/>
      </div>
    HTML
  end

  def gender_field(required: false)
    <<-HTML
      <div class='form-row'>
        <label for='gender'>
          #{t("external_form_js.gender")} #{required ? '*' : ''}
        </label>
        <label for='gender_not_stated' style='width: auto'>
          <input name='externally_submitted_person[gender]' type='radio' id='gender_not_stated' value='' checked='checked' style='width: 2rem'/>
          #{t("external_form_js.genders.not_stated")}
        </label>
        <label for='gender_m' style='width: auto'>
          <input name='externally_submitted_person[gender]' type='radio' id='gender_m' value='m' style='width: 2rem'/>
          #{t("external_form_js.genders.m")}
        </label>
        <label for='gender_w' style='width: auto'>
          <input name='externally_submitted_person[gender]' type='radio' id='gender_w' value='w' style='width: 2rem'/>
          #{t("external_form_js.genders.w")}
        </label>
        <label for='gender_diverse' style='width: auto'>
          <input name='externally_submitted_person[gender]' type='radio' id='gender_diverse' value='' style='width: 2rem'/>
          #{t("external_form_js.genders.diverse")}
        </label>
      </div>
    HTML
  end
end
