class Notifier < ApplicationMailer
  default from: 'hitobito-glp@grunliberale.ch'

  def mitglied_left person, email
    @person = person
    mail(to: email)
  end

  def mitglied_joined person, email
    @person = person
    mail(to: email)
  end
end
