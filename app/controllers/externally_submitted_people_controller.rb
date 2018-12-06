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

  def create
    I18n.locale = params[:locale] || "de"
    if !is_captcha_valid?
      render json: {error: t("external_form_js.server_error_captcha")}, status: :unprocessable_entity
      return
    end
    begin
      ActiveRecord::Base.transaction do
        @person = Person.create!(first_name: first_name,
                                 last_name: last_name,
                                 email: email,
                                 zip_code: zip_code,
                                 preferred_language: preferred_language)

        if zip_codes_matching_groups.any?
          zip_codes_matching_groups.each do |group|
            case submitted_role
            when "Mitglied"
              if zugeordnete_children(group).any?
                put_him_into_zugeordnete_children zugeordnete_children(group)
              else
                put_him_into_root_zugeordnete_groups
              end
              send_him_a_mitglied_welcome_email
              notify_parent_group
            when "Sympathisant"
              if zugeordnete_children(group).any?
                put_him_into_zugeordnete_children zugeordnete_children(group)
              else
                put_him_into_root_zugeordnete_groups
              end
              send_him_a_sympathisant_welcome_email
            when "Medien_und_dritte"
              if kontakte_children(group).any?
                put_him_into_kontakte_children kontakte_children(group)
              else
                put_him_into_root_kontakte_groups
              end
              send_him_a_medien_und_dritte_welcome_email
            end
          end
        else
          case submitted_role
          when "Mitglied"
            put_him_into_root_zugeordnete_groups
            send_him_a_mitglied_welcome_email
            send_him_login_information
            notify_parent_group
          when "Sympathisant"
            put_him_into_root_zugeordnete_groups
            send_him_a_sympathisant_welcome_email
          when "Medien_und_dritte"
            put_him_into_root_kontakte_groups
            send_him_a_medien_und_dritte_welcome_email
          end
        end
        notify_monitoring_address
      end
      render json: @person, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      if e.message =~ /e-mail/i || e.message =~ /email/i
        render json: {error: t("external_form_js.submit_error_email_taken")}, status: :unprocessable_entity
      else
        render json: {error: t("external_form_js.submit_error")}, status: :unprocessable_entity
      end
    end

  end

  private

  def send_him_a_mitglied_welcome_email
    Notifier.welcome_mitglied(@person, preferred_language).deliver_now
  end

  def send_him_a_sympathisant_welcome_email
    Notifier.welcome_sympathisant(@person, preferred_language).deliver_now
  end

  def send_him_a_medien_und_dritte_welcome_email
    Notifier.welcome_medien_und_dritte(@person, preferred_language).deliver_now
  end

  def notify_parent_group
    zugeordnete_roles_where_he_is_a_mitglied = @person.zugeordnete_roles_where_he_is_a_mitglied

    if zugeordnete_roles_where_he_is_a_mitglied.any?
      zugeordnete_parent_groups = zugeordnete_roles_where_he_is_a_mitglied.map(&:group).map(&:parent).uniq

      zugeordnete_parent_groups.each do |group|
        if group.email.present?
          Notifier.mitglied_joined(@person, group.email).deliver_now
        end
      end
    end
  end

  def notify_monitoring_address
    Notifier.mitglied_joined_monitoring(@person, submitted_role, 'mitgliederdatenbank@grunliberale.ch').deliver_now
  end

  def put_him_into_root_zugeordnete_groups
    root_zugeordnete_groups.each do |group|
      Role.create(type:   zugeordnete_role_type,
                  person: @person,
                  group:  group)
    end
  end

  def put_him_into_root_kontakte_groups
    root_kontakte_groups.each do |group|
      Role.create!(type:   kontakte_role_type,
                   person: @person,
                   group:  group)
    end
  end

  def root_zugeordnete_groups
    Group.where(type: "Group::RootZugeordnete")
  end

  def root_kontakte_groups
    Group.where(type: "Group::RootKontakte")
  end

  def zugeordnete_role_type
    "Group::RootZugeordnete::#{submitted_role}"
  end

  def kontakte_role_type
    "Group::RootKontakte::Kontakt"
  end

  def zip_codes_matching_groups
    groups_with_zip_codes = Group.where.not(zip_codes: '').where.not(type: 'Group::Root')
    groups_with_zip_codes.select do |group|
      group.zip_codes.split(",").map(&:strip).include? externally_submitted_person_params[:zip_code]
    end
  end

  def put_him_into_zugeordnete_children zugeordnete_children
    zugeordnete_children.each do |zugeordnete_child|
      Role.create!(type:   "#{zugeordnete_child.type}::#{submitted_role}",
                   person: @person,
                   group:  zugeordnete_child)
    end
  end

  def put_him_into_kontakte_children kontakte_children
    kontakte_children.each do |kontakte_child|
      Role.create!(type:   "#{kontakte_child.type}::Kontakt",
                   person: @person,
                   group:  kontakte_child)
    end
  end

  def zugeordnete_children group
    if group.children.any?
      group.children.select{ |child| child.type.include?("Zugeordnete")}
    else
      []
    end
  end

  def kontakte_children group
    if group.children.any?
      group.children.select{ |child| child.type.include?("Kontakte")}
    else
      []
    end
  end

  def submitted_role
    externally_submitted_person_params[:role].capitalize
  end

  def first_name
    externally_submitted_person_params[:first_name]
  end

  def last_name
    externally_submitted_person_params[:last_name]
  end

  def email
    externally_submitted_person_params[:email]
  end

  def preferred_language
    externally_submitted_person_params[:preferred_language]
  end

  def zip_code
    externally_submitted_person_params[:zip_code]
  end

  def externally_submitted_person_params
    params.require(:externally_submitted_person).permit(:email, :zip_code, :role, :first_name, :last_name, :preferred_language, :terms_and_conditions)
  end
end
