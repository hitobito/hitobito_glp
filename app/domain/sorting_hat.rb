# Wird via externem Formular angestossen
#  Mitglied -> Gruppe Zugeordnete
#  Sympathisant -> Gruppe Zugeordnete
#  Medien_und_dritte -> Gruppe Medien_und_dritte
#
# in dem entsprechenden Kanton, falls die Zip dort definiert ist, sonst in der Root Gruppe
# -> allerdings zip_codes nur für 2 Kantone definiert (stand 5 März 2020)
#
# Junge GLP
# -> nur Gruppe Mitglieder und Sympathisanten
#
# Fragen zu glp#7
# -> Alle Rollen in Mitglieder und Sympathisanten od. Gruppen entsprechend Kanton ergänzen?
# -> Falls keine zuordnung über zip, person unter Root Gruppe oder jGLP, welche untergruppe?
#
#
# !!! Wo ist das Formular für integration !!!

class SortingHat
  attr_reader :submitted_role, :person, :jglp

  FOREIGN_ZIP_CODE = 102
  JGLP_ZIP_CODE    = 103

  MONITORING_EMAIL = 'mitgliederdatenbank@grunliberale.ch'
  JGLP_EMAIL = 'junge@grunliberale.ch'

  def self.locked?(group)
    [FOREIGN_ZIP_CODE, JGLP_ZIP_CODE].any? { |code| code.to_s == group.zip_codes }
  end

  def initialize(person, submitted_role, jglp)
    @person = person
    @submitted_role = submitted_role
    @jglp = jglp
  end

  def sing
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
    notify_youth_address if jglp
  end

  def zip_code
    person.zip_code.to_s.length != 4 ? FOREIGN_ZIP_CODE : person.zip_code
  end

  private

  def preferred_language
    person.preferred_language
  end

  def top_level_group
    jglp ? Group.find_by(zip_codes: JGLP_ZIP_CODE) : Group::Root.first
  end

  # eventuell like query?
  def zip_codes_matching_groups
    top_level_group.descendants.with_zip_codes.select do |group|
      group.zip_codes.split(",").map(&:strip).include?(zip_code.to_s)
    end
  end

  def send_him_a_mitglied_welcome_email
    Notifier.welcome_mitglied(@person, preferred_language).deliver_later
  end

  def send_him_a_sympathisant_welcome_email
    Notifier.welcome_sympathisant(@person, preferred_language).deliver_later
  end

  def send_him_a_medien_und_dritte_welcome_email
    Notifier.welcome_medien_und_dritte(@person, preferred_language).deliver_later
  end

  def notify_parent_group
    zugeordnete_roles_where_he_is_a_mitglied = @person.zugeordnete_roles_where_he_is_a_mitglied

    if zugeordnete_roles_where_he_is_a_mitglied.any?
      zugeordnete_parent_groups = zugeordnete_roles_where_he_is_a_mitglied
        .map(&:group).map(&:parent).uniq

      zugeordnete_parent_groups.each do |group|
        if group.email.present?
          Notifier.mitglied_joined(@person, group.email, jglp).deliver_later
        end
      end
    end
  end

  def notify_monitoring_address
    Notifier.mitglied_joined_monitoring(@person,
                                        submitted_role,
                                        MONITORING_EMAIL,
                                        jglp).deliver_later
  end

  def notify_youth_address
    Notifier.mitglied_joined_monitoring(@person,
                                        submitted_role,
                                        JGLP_EMAIL,
                                        jglp).deliver_later
  end

  def put_him_into_root_zugeordnete_groups
    root_zugeordnete_groups.each do |group|
      Role.create(type:   role_type(group),
                  person: @person,
                  group:  group)
    end
  end

  def put_him_into_root_kontakte_groups
    root_kontakte_groups.each do |group|
      Role.create!(type:   role_type(group),
                   person: @person,
                   group:  group)
    end
  end

  def root_zugeordnete_groups
    top_level_group.descendants.where(type: group_type('Zugeordnete'))
  end

  def root_kontakte_groups
    top_level_group.descendants.where(type: group_type('Kontakte'))
  end

  def group_type(type)
    top_level_type = top_level_group.class.to_s.demodulize
    "Group::#{top_level_type}#{type}"
  end

  def put_him_into_zugeordnete_children zugeordnete_children
    zugeordnete_children.each do |zugeordnete_child|
      Role.create!(type:   role_type(zugeordnete_child),
                   person: @person,
                   group:  zugeordnete_child)
    end
  end

  def put_him_into_kontakte_children kontakte_children
    kontakte_children.each do |kontakte_child|
      Role.create!(type:   role_type(kontakte_child),
                   person: @person,
                   group:  kontakte_child)
    end
  end

  def role_type(group)
    inferred_role = submitted_role == 'Medien_und_dritte' ? 'Kontakt' : submitted_role
    "#{group.type}::#{inferred_role}"
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

end
