# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'twilio-ruby'

module TwoFactorAuthentication
  TOO_MANY_TRIES = 5

  def first_factor_authenticated?
    two_fa_person && two_fa_person.valid_password?(params[:person][:password])
  end

  def two_factor_authentication_required?
    two_fa_person.two_factor_authentication_required?
  end

  def too_many_tries?
    if two_fa_person.second_factor_generated_at &&
        two_fa_person.second_factor_generated_at.to_date == Time.zone.now.to_date
      two_fa_person.second_factor_unsuccessful_tries >= TOO_MANY_TRIES
    else
      two_fa_person.update!(second_factor_unsuccessful_tries: 0)
      false
    end
  end

  def send_two_factor_authentication_code
    # generate code
    code = generate_authentication_code
    # save to db
    two_fa_person.second_factor_code = code
    two_fa_person.second_factor_generated_at = Time.zone.now
    two_fa_person.second_factor_unsuccessful_tries += 1
    two_fa_person.save!
    # send code via twilio
    send_authentication_code(two_fa_person, code)
  end

  def two_factor_authenticate(code)
    if two_fa_person.second_factor_generated_at < (Time.zone.now - 5.minutes)
      false
    elsif two_fa_person.second_factor_code == code
      two_fa_person.update!(second_factor_unsuccessful_tries: 0)
      true
    else
      false
    end
  end

  private

  def generate_authentication_code
    characters = (0..9).to_a
    Array.new(6) { characters.sample }.join
  end

  def send_authentication_code(person, code)
    mobile_phone_number = get_phone_number(person)
    return false unless mobile_phone_number
    twilio_client.messages.create(
      from: 'glp',
      to: mobile_phone_number,
      body: "#{code} ist dein 2FA-Code für glp community."
    )
    true
  rescue
    return false
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(
      'AC430f75edbbf4afa71f37e5a1e2a2b97c',
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def get_phone_number(person)
    mobile_phone_number = person.phone_numbers.find_by(label: 'Mobil')
    if mobile_phone_number
      normalize_phone_number(mobile_phone_number.number.gsub(/\s+/, ''))
    else
      false
    end
  end

  def normalize_phone_number(mobile_phone_number)
    if mobile_phone_number.length == 10 && mobile_phone_number.starts_with?('0')
      '+41' + mobile_phone_number[1..-1] # 079 123 45 67
    elsif mobile_phone_number.length == 12 && mobile_phone_number.starts_with?('+41')
      mobile_phone_number # +41 79 123 45 67
    elsif mobile_phone_number.length == 13 && mobile_phone_number.starts_with?('0041')
      '+' + mobile_phone_number[2..-1] # 0041 79 123 45 67
    else
      false
    end
  end
end
