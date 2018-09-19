class Notifier < ApplicationMailer
  default from: 'hitobito-glp@grunliberale.ch'

  def zip_code_changed person, email
    @person = person
    mail(to: email)
  end

  def mitglied_left person, email
    @person = person
    mail(to: email)
  end

  def mitglied_joined person, email
    @person = person
    mail(to: email, subject: "Achtung: Neues Mitglied.")
  end

  def welcome_mitglied person, locale
    @person = person
    @locale = locale
    I18n.locale = @locale
    mail(to: @person.email, from: t(".from"), subject: t(".subject"))
  end

  def welcome_sympathisant person, locale
    @person = person
    @locale = locale
    I18n.locale = @locale
    mail(to: @person.email, from: t(".from"), subject: t(".subject"))
  end

  def welcome_medien_und_dritte person, locale
    @person = person
    @locale = locale
    I18n.locale = @locale
    mail(to: @person.email, from: t(".from"), subject: t(".subject"))
  end
end
