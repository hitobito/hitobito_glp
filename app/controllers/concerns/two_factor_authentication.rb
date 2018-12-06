require 'twilio-ruby'

module Concerns
  module TwoFactorAuthentication
    TWO_FACTOR_GROUPS = [
      Group::Root
    ].freeze
    TOO_MANY_TRIES = 5

    def first_factor_authenticated?
      person && person.valid_password?(params[:person][:password])
    end

    def two_factor_authentication_required?
      (person.groups & TWO_FACTOR_GROUPS.map(&:all).flatten).any?
    end

    def too_man_tries?
      if person.second_factor_generated_at &&
         person.second_factor_generated_at.to_date == Time.zone.now.to_date
        person.second_factor_unsuccessful_tries >= TOO_MANY_TRIES
      else
        person.update!(second_factor_unsuccessful_tries: 0)
        false
      end
    end

    def send_two_factor_authentication_code
      # generate code
      code = generate_authentication_code
      # save to db
      person.second_factor_code = code
      person.second_factor_generated_at = Time.zone.now
      person.second_factor_unsuccessful_tries += 1
      person.save!
      # send code via twilio
      send_authentication_code(person, code)
    end

    def two_factor_authenticate(code)
      if person.second_factor_generated_at < (Time.zone.now - 5.minutes)
        false
      elsif person.second_factor_code == code
        person.update!(second_factor_unsuccessful_tries: 0)
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
end
