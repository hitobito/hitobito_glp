# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require "uri"
require "net/http"

class ExternallySubmittedPeopleController < ApplicationController
  skip_authorization_check
  skip_before_action :verify_authenticity_token

  respond_to :js

  def devise_controller?
    true
  end

  def is_captcha_valid?
    if Rails.env == "test"
      true
    else
      response = Net::HTTP.post_form(URI.parse("https://www.google.com/recaptcha/api/siteverify"), {
        secret: "6LcBNGoUAAAAAKoQO8Rvw_H5DlKKkR64Q1ZoP3Is",
        response: params["g-recaptcha-response"]
      })
      return JSON.parse(response.body)["success"] || false
    end
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    I18n.locale = params[:locale] || "de"
    if !is_captcha_valid?
      render({
        json: {error: t("external_form_js.server_error_captcha")},
        status: :unprocessable_entity
      })
      return
    end
    ActiveRecord::Base.transaction do
      attrs = model_params.except(:role, :terms_and_conditions, :address,
                                  :house_number, :phone_number)

      attrs[:address] = [model_params[:address], model_params[:house_number]].join(' ')
      attrs[:phone_numbers_attributes] = phone_numbers_attributes if model_params[:phone_number]
      attrs[:preferred_language] = 'de' if attrs[:preferred_language].blank?

      @person = Person.new(attrs)
      if @person.save
        SortingHat::Song.new(@person, submitted_role, jglp).sing
        render json: PersonSerializer.new(@person.decorate,
                                          group: @person.primary_group,
                                          controller: self),
                                          status: :ok
      else
        errors = @person.errors
        taken_email = errors.find { |e| e.attribute == :email && e.type == :taken }
        message = if taken_email
                    # show only this since it means they already own an account
                    # and the message advises them to not fill out the form
                    t("external_form_js.submit_error_email_taken")
                  else
                    errors.uniq(&:attribute).map(&:full_message).join(', ')
                  end
        render({
          json: { error: message },
          status: :unprocessable_entity
        })
      end
    end
  end

  private
  
  # Since there is no current_user but the serializer tries to make a can? call,
  # we need to define an ability using nil as current_user
  def current_ability
    @current_ability ||= ::Ability.new(nil)
  end

  def submitted_role
    model_params[:role].capitalize
  end

  def jglp
    params.fetch(:externally_submitted_person, {})[:jglp]
  end

  def model_params
    params.require(:externally_submitted_person).permit(:email,
                                                        :zip_code,
                                                        :role,
                                                        :first_name,
                                                        :last_name,
                                                        :address,
                                                        :house_number,
                                                        :town,
                                                        :phone_number,
                                                        :gender,
                                                        :birthday,
                                                        :preferred_language,
                                                        :terms_and_conditions)
  end

  def phone_numbers_attributes
    {
      :'0' => {
        number: model_params[:phone_number],
        label: PhoneNumber.predefined_labels.first
      }
    }
  end
end
