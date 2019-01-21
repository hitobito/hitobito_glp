module Glp::MailingList
  extend ActiveSupport::Concern


  included do
    alias_method_chain :people, :filter
  end

  def people_with_filter(people_scope = Person.only_public_data)
    people_without_filter(people_scope)
      .where(attributes_conditions_with_explicit_subscribers)
  end

  def genders_array
    genders ? genders.split(",").map { |g| g == '_nil' ? nil : g } : []
  end

  def languages_array
    languages ? languages.split(",") : []
  end

  private

  def attributes_conditions_with_explicit_subscribers
    if attribute_conditions.present?
      attribute_conditions.join(' AND ') << " OR #{explicitly_subscribed})"
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
      sanitize_sql(['birthday <= ?', Time.zone.now - age_start.years])
    end
  end

  def age_finish_condition
    if age_finish.present?
      sanitize_sql(['birthday >= ?', Time.zone.now - age_finish.years])
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
    subscribed = Subscription.select(:subscriber_id).
      where(mailing_list_id: id,
            excluded: false,
            subscriber_type: Person.sti_name)
    sanitize_sql(id: subscribed)
  end

  def sanitize_sql(*attrs)
    Person.where(*attrs).to_sql.split('WHERE ')[1]
  end


end
