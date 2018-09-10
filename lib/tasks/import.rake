require 'aws-sdk'
require 'dotenv/tasks'

namespace :import do
  task historical_data: :environment do
    Aws.config[:credentials] = Aws::Credentials.new(ENV["ACCESS_KEY_ID"], ENV["SECRET_ACCESS_KEY"])
    s3 = Aws::S3::Resource.new(region: 'us-east-2')
    object = s3.bucket('zw-glp').object(ENV["OBJECT_NAME"])
    content = object.get().body.read
    puts

    CSV.parse(content)[1..-1].each do |row|
      old_id, category, _, _, preferred_language, _, company, title, _, first_name,
        last_name, street, address_additional, zip_code, town, _, address_foreign,
        email, additional_email, phone_private, phone_business, phone_mobile,
        birth_date, place_of_origin, occupation, interested, short_name, joined_at,
        joining_journey, _, left_at, interests, _ = row

      group_type, role, comment = group_type_and_role_for_category(category)
      additional_information_category = comment ? comment : ""

      person = Person.new(
        preferred_language: preferred_language,
        company_name: company,
        company: !company.blank?,
        title: title,
        first_name: first_name,
        last_name: last_name,
        address: street,
        zip_code: parse_zip_code(zip_code),
        town: town,
        email: email,
        birthday: parse_date(birth_date),
        occupation: occupation,
        nickname: short_name,
        joined_at: parse_date(joined_at),
        joining_journey: joining_journey,
        left_at: parse_date(left_at),
        gender: determine_gender(title),
        additional_information: generate_additional_information([
          ["Adress-Zusatz", address_additional],
          ["Ausland-Adresse", address_foreign],
          ["Aktive Mitarbeit", interested == "0" ? "" : "Interessiert"],
          ["Interessen", interests],
          ["glp-net Kategorie", additional_information_category]
        ]),
        phone_numbers: generate_phone_numbers(phone_private, phone_business, phone_mobile),
        additional_emails: generate_additional_emails(additional_email),
        place_of_origin: place_of_origin
      )

      group = group_for_zip_code_with_group_type(zip_code, group_type)
      group ||= root_group_with_group_type(group_type)
      if group
        begin
          person.save!
          role = Role.create!(
            type:   "#{group.type}::#{role}",
            person: person,
            group:  group
          )
        rescue => error
          debug_failure_for_person "Validations failed", old_id, error
        end
      else
        debug_failure_for_person "No matching groups found", old_id
      end
    end
  end
end

def group_type_and_role_for_category category
  medien_und_andere_dritte = ["Kontakte", "Kontakt"]
  sympathisant = ["Zugeordnete", "Sympathisant"]
  mitglied = ["Zugeordnete", "Mitglied"]
  mitarbeiter_in = ["Geschaeftsstelle", "Mitarbeiter"]
  case category
  when "Medien"
    medien_und_andere_dritte
  when "Sympathisant/in"
    sympathisant
  when "Einzelmitglied"
    mitglied
  when "Mitarbeiter/in ohne Mitgliedschaft"
    mitarbeiter_in
  when "Wenigverdienende/r"
    return *mitglied, "Wenigverdienende"
  when "Paarmitglied"
    return *mitglied, "Paarmitglied"
  when "Student / in Ausbildung"
    return *mitglied, "Student"
  when "Interessensvertreter/in"
    return *medien_und_andere_dritte, "Interessensvertreter"
  when "andere Partei / Org."
    medien_und_andere_dritte
  when "Rentner/in"
    return *mitglied, "Rentner"
  when "Gönner/in"
    return *medien_und_andere_dritte, "Gönner"
  when "Behörde"
    return *medien_und_andere_dritte, "Behörde"
  else
    medien_und_andere_dritte
  end
end

def group_for_zip_code_with_group_type zip_code, group_type
  groups_with_zip_codes = Group.without_deleted.where.not(zip_codes: '').where.not(type: 'Group::Root')
  matching_groups = groups_with_zip_codes.select do |group|
    group.zip_codes.split(",").map(&:strip).include? zip_code
  end

  if matching_groups.any?
    if matching_groups.first.children.any?
      matching_groups = matching_groups.first.children.select do |child|
        child.type.end_with? group_type
      end
      if matching_groups.any?
        return matching_groups.first
      end
    end
  end
  return false
end

def root_group_with_group_type group_type
  root_group = Group.without_deleted.find_by(type: "Group::Root")
  if root_group && root_group.children.any?
    matching_root_group = root_group.children.select do |child|
      child.type.end_with? group_type
    end
    if matching_root_group.any?
      return matching_root_group.first
    end
  end
  return false
end

def generate_additional_information additional_information_items
  additional_information_items.keep_if do |additional_information_item|
    !additional_information_item[1].blank?
  end.map do |additional_information_item|
    "#{additional_information_item[0]}: #{additional_information_item[1]}"
  end.join("\n")
end

def generate_phone_numbers phone_private, phone_business, phone_mobile
  phone_numbers = []
  if !phone_private.blank?
    phone_numbers << PhoneNumber.new(number: phone_private, label: "Privat", public: false)
  end
  if !phone_business.blank?
    phone_numbers << PhoneNumber.new(number: phone_business, label: "Geschäft", public: false)
  end
  if !phone_mobile.blank?
    phone_numbers << PhoneNumber.new(number: phone_mobile, label: "Mobil", public: false)
  end
  return phone_numbers
end

def generate_additional_emails(additional_email)
  if !additional_email.blank?
    [AdditionalEmail.new(email: additional_email, label: "Zweite Emailadresse")]
  else
    []
  end
end

def parse_zip_code zip_code
  zip_code.length == 4 ? zip_code : nil
end

def parse_date date
  Date.parse(date)
rescue
  nil
end

def determine_gender title
  case title
  when "Herr"
    :m
  when "Monsieur"
    :m
  when "Signor"
    :m
  when "Frau"
    :w
  when "Madame"
    :w
  when "Mademoiselle"
    :w
  when "Signora"
    :w
  else
    nil
  end
end

def debug_failure_for_person message, id, error = false
  puts "- Person with old Addr-ID '#{id}' not added: #{message}"
  puts "  #{error}" unless !error
  puts
end
