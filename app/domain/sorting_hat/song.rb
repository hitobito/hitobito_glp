# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module SortingHat
  class Song

    def initialize(person, role, jglp)
      @person = person
      @role = role
      @jglp = jglp
      @zip = person.zip_code
    end

    def sing
      raise ArgumentError.new("Role #{@role} is not supported") unless role_valid?

      groups = finder.groups
      groups.each do |group|
        create_role(group)
        notify_parent_group(group) if mitglied?
      end

      notify_layer_admins(groups)
      notify_youth_address if jglp?
      notify_monitoring_address

      send_welcome_mail
    end

    private

    def create_role(group)
      role_type = medien? ? 'Kontakt' : @role
      group.roles.create!(type: "#{group.class.sti_name}::#{role_type}", person: @person)
    end

    def finder
      @finder ||= SortingHat::Finder.new(@role, @zip, @jglp)
    end

    def jglp?
      @jglp
    end

    def mitglied?
      @role == 'Mitglied'
    end

    def medien?
      @role == 'Medien_und_dritte'
    end

    def role_valid?
      ROLES.keys.include?(@role)
    end

    def send_welcome_mail
      Notifier.send("welcome_#{@role.downcase}", @person, @person.preferred_language).deliver_later
    end

    def notify_monitoring_address
      Notifier.mitglied_joined_monitoring(@person, @role, MONITORING_EMAIL, jglp?).deliver_later
    end

    def notify_youth_address
      Notifier.mitglied_joined_monitoring(@person, @role, JGLP_EMAIL, jglp?).deliver_later
    end

    def notify_parent_group(group)
      if group.parent.email && group.parent.email != JGLP_EMAIL
        Notifier.mitglied_joined(@person, group.parent.email, jglp?).deliver_later
      end
    end

    def notify_layer_admins(groups)
      parent_groups = groups.flat_map(&:layer_hierarchy)
      scope = Person.admin.notify_on_join.where(roles: { group: parent_groups } )
      scope.distinct.find_each do |admin|
        Notifier.mitglied_joined_monitoring(@person, @role, admin.email, jglp?).deliver_later
      end
    end
  end
end
