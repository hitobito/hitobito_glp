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
end
