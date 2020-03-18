class SortingHat
  attr_reader :submitted_role, :person, :jglp

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

  private

  def zip_code
    person.zip_code
  end

  def preferred_language
    person.preferred_language
  end

  # eventuell like query?
  def zip_codes_matching_groups
    groups_with_zip_codes = Group.where.not(zip_codes: '').where.not(type: 'Group::Root')
    groups_with_zip_codes.select do |group|
      group.zip_codes.split(",").map(&:strip).include?(zip_code)
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
                                        'mitgliederdatenbank@grunliberale.ch',
                                        jglp).deliver_later
  end

  def notify_youth_address
    Notifier.mitglied_joined_monitoring(@person,
                                        submitted_role,
                                        'junge@grunliberale.ch',
                                        jglp).deliver_later
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

end
