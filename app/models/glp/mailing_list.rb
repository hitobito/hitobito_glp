module Glp::MailingList
  extend ActiveSupport::Concern

  included do
    alias_method_chain :people, :filter
  end

  def people_with_filter(people_scope = Person.only_public_data)
    people_without_filter(people_scope)
      .where(age_start_condition)
      .where(age_finish_condition)
      .where(gender_condition)
      .where(language_condition)
  end

  def genders_array
    genders ? genders.split(",").map { |g| g == '_nil' ? nil : g } : []
  end

  def languages_array
    languages ? languages.split(",") : []
  end

  private

  def age_start_condition
    if age_start.present?
      birthday_finish = DateTime.now - age_start.years
      return "birthday <= ?", birthday_finish
    end
  end

  def age_finish_condition
    if age_finish.present?
      birthday_start = DateTime.now - age_finish.years
      return "birthday >= ?", birthday_start
    end
  end

  def gender_condition
    if genders.present?
      return :gender => genders_array unless genders_array.empty?
    end
  end

  def language_condition
    if languages.present?
      return :preferred_language => languages_array unless languages_array.empty?
    end
  end
end
