#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::MailingList
  extend ActiveSupport::Concern

  included do
    alias_method_chain :people, :filter
  end

  def people_with_filter(people_scope = Person.only_public_data)
    people_without_filter(people_scope)
      .where(attributes_conditions_with_explicit_subscribers)
  end

  def gender_value(gender)
    genders_array.include?((gender == "_nil") ? nil : gender)
  end

  def language_value(language)
    languages_array.include?(language.to_s)
  end

  private

  def attributes_conditions_with_explicit_subscribers
    conditions = attribute_conditions.join(" AND ")
    return if conditions.blank?

    if explicitly_subscribed.present?
      conditions << " OR #{sanitize_sql(id: explicitly_subscribed.pluck(:subscriber_id))}"
    else
      conditions
    end
  end

  def attribute_conditions
    [age_start_condition,
      age_finish_condition,
      gender_condition,
      language_condition].compact
  end

  def age_start_condition
    if age_start.present?
      sanitize_sql(["birthday <= ?", Time.zone.now - age_start.years])
    end
  end

  def age_finish_condition
    if age_finish.present?
      sanitize_sql(["birthday >= ?", Time.zone.now - age_finish.years])
    end
  end

  def gender_condition
    if genders_array.present?
      sanitize_sql(gender: genders_array)
    end
  end

  def language_condition
    if languages_array.present?
      sanitize_sql(preferred_language: languages_array)
    end
  end

  def explicitly_subscribed
    @explicitly_subscribed ||= Subscription.select(:subscriber_id)
      .where(mailing_list_id: id,
        excluded: false,
        subscriber_type: Person.sti_name)
  end

  def sanitize_sql(*attrs)
    Person.where(*attrs).to_sql.split("WHERE ")[1]
  end

  def genders_array
    return [] unless genders

    genders.split(",").map { |g| (g == "_nil") ? nil : g }
  end

  def languages_array
    languages ? languages.split(",") : []
  end
end
