# frozen_string_literal: true

#  Copyright (c) 2012-2023, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class NotifierMailer < ApplicationMailer
  def zip_code_changed(person, email)
    @person = person
    mail(to: email)
  end

  def mitglied_left(attrs, email)
    @person = Person.new(attrs)
    mail(to: email)
  end

  def mitglied_joined(person, email, jglp)
    @person = person
    @preferred_language = preferred_language(person)
    @jglp = jglp
    mail(to: email, subject: "Achtung: Neues Mitglied.")
  end

  def mitglied_joined_monitoring(person, submitted_role, email, jglp) # rubocop:disable Metrics/MethodLength it would be better to create 3-4 separate methods out of this
    @person = person
    @category = submitted_role
    @preferred_language = preferred_language(person)
    @jglp = jglp

    case submitted_role
    when "Mitglied"
      @subject = "Achtung: Neues Mitglied"
      @welcome = "Ein neues Mitglied hat sich registriert."
    when "Sympathisant"
      @subject = "Achtung: Neue/r Sympathisant/in"
      @welcome = "Ein/e neue/r Sympathisant/in hat sich registriert."
    when "Medien_und_dritte"
      @subject = "Achtung: Neue News-Anmeldung"
      @welcome = "Es gibt eine neue Anmeldung für Partei-News."
      @category = "Medien & Dritte"
    else
      @subject = "Achtung: Neue Anmeldung"
      Sentry.with_scope do |scope|
        scope.set_context(category: submitted_role, person_id: person.id)
        Sentry.capture_message("Unerwartete Kategorie in 'mitglied_joined_monitoring'")
      end
    end

    mail(to: email, subject: @subject)
  end

  def welcome_mitglied(person, locale)
    @person = person
    @locale = locale
    I18n.locale = @locale

    token = @person.generate_reset_password_token!
    @login_url = edit_person_password_url(reset_password_token: token)

    mail(to: @person.email, subject: t(".subject"))
  end

  def welcome_sympathisant(person, locale)
    @person = person
    @locale = locale
    I18n.locale = @locale
    mail(to: @person.email, subject: t(".subject"))
  end

  def welcome_medien_und_dritte(person, locale)
    @person = person
    @locale = locale
    I18n.locale = @locale
    mail(to: @person.email, subject: t(".subject"))
  end

  def preferred_language(person)
    Settings.application.languages.to_hash[person.preferred_language.to_s.to_sym]
  end
end
