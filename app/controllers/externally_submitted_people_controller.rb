class ExternallySubmittedPeopleController < ApplicationController
  skip_authorization_check
  skip_before_action :verify_authenticity_token

  respond_to :js

  def devise_controller?
    true
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @person = Person.create!(first_name: first_name,
                                 last_name: last_name,
                                 email: email,
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
              send_him_login_information
              notify_parent_group
            when "Sympathisant"
              if zugeordnete_children(group).any?
                put_him_into_zugeordnete_children zugeordnete_children(group)
              else
                put_him_into_root_zugeordnete_groups
              end
            when "Adressverwaltung"
              if kontakte_children(group).any?
                put_him_into_kontakte_children kontakte_children(group)
              else
                put_him_into_root_kontakte_groups
              end
            end
          end
        else
          case submitted_role
          when "Mitglied", "Sympathisant"
            put_him_into_root_zugeordnete_groups
          when "Adressverwaltung"
            put_him_into_root_kontakte_groups
          end
        end
      end
      render json: @person, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: {error: e.message}, status: :unprocessable_entity
    end

  end

  private

  def send_him_login_information
    admin_role = Role.where(type: "Group::Root::Administrator").first
    admin = Person.find(admin_role.person_id)
    Person::SendLoginJob.new(@person, admin).enqueue!
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
    "Group::RootKontakte::#{submitted_role}"
  end

  def zip_codes_matching_groups
    groups_with_zip_codes = Group.where.not(zip_codes: '')
    groups_with_zip_codes.select do |group|
      group.zip_codes.split(",").map(&:strip).include? externally_submitted_person_params[:zip_code]
    end
  end

  def zugeordnete_children group
    if group.children.any?
      @zugeordnete_children ||= group.children.select{ |child| child.type.include?("Zugeordnete")}
    else
      []
    end
  end

  def kontakte_children group
    if group.children.any?
      @kontakte_children ||= group.children.select{ |child| child.type.include?("Kontakte")}
    else
      []
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
      Role.create!(type:   "#{kontakte_child.type}::#{submitted_role}",
                   person: @person,
                   group:  kontakte_child)
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

  def externally_submitted_person_params
    params.require(:externally_submitted_person).permit(:email, :zip_code, :role, :first_name, :last_name, :preferred_language)
  end
end
