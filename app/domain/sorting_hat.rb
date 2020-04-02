# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class SortingHat
  FOREIGN_ZIP_CODE = 102
  JGLP_ZIP_CODE    = 103

  MONITORING_EMAIL = 'mitgliederdatenbank@grunliberale.ch'
  JGLP_EMAIL = 'junge@grunliberale.ch'

  ROLES = %w[
    Mitglied
    Sympathisant
    Medien_und_dritte
  ].freeze

  def self.locked?(group)
    [FOREIGN_ZIP_CODE, JGLP_ZIP_CODE].any? { |code| code.to_s == group.zip_codes }
  end

  def initialize(person, role, jglp)
    @person = person
    @role = role
    @jglp = jglp
    @zip = person.zip_code
  end

  def sing
    raise ArgumentError.new("Role #{@role} is not supported") unless role_valid?

    create_role
    send_welcome_mail
    notify_parent_group if mitglied?
    notify_youth_address if jglp?
    notify_monitoring_address
  end

  def group
    @group ||= find_group
  end

  private

  def create_role
    role_type = medien? ? 'Kontakt' : @role
    group.roles.create!(type: "#{group.class.sti_name}::#{role_type}", person: @person)
  end

  def send_welcome_mail
    send("send_him_a_#{role.downcase}_welcome_email")
  end

  def find_group
    if jglp?
      find_group_for_role_and_zip(jglp_group)
    elsif foreign?
      find_group_for_role(foreign_group)
    else
      find_group_for_role_and_zip(root_group)
    end
  end

  def find_group_for_role_and_zip(parent)
    parent ||= root_group # use root_group in case we have not parent

    groups_for_zip = zip? ? parent.children.where('zip_codes LIKE ?', "%#{@zip}%") : Group.none
    group = find_group_for_role(groups_for_zip.first) if groups_for_zip.one?

    group || find_group_for_role(parent)
  end

  def find_group_for_role(group)
    group_type = medien? ? 'Kontakte' : 'Zugeordnete'
    group.children.find_by(type: "#{group.type}#{group_type}")
  end

  def foreign_group
    @foreign_group ||= Group.find_by(zip_codes: SortingHat::FOREIGN_ZIP_CODE)
  end

  def jglp_group
    @jglp_group ||= Group.find_by(zip_codes: SortingHat::JGLP_ZIP_CODE)
  end

  def root_group
    @root_group ||= Group::Root.first
  end

  def foreign?
    zip? && @zip.size != 4
  end

  def zip?
    @zip.present?
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
    ROLES.include?(@role)
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

  def notify_parent_group
    Notifier.mitglied_joined(@person, group.parent.email, jglp?).deliver_later if group.parent.email
  end
end
