#  Copyright (c) 2020, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Glp::Person::Subscriptions

  def mailing_lists
    super
      .where(filter_by_gender)
      .where(filter_by_age_start)
      .where(filter_by_age_finish)
      .where(filter_by_language)
      .or(MailingList.distinct.where(id: direct.select('mailing_list_id')))
  end

  def filter_by_gender
    ["(genders IS NULL OR genders = '' OR genders LIKE ?)", val(:gender)]
  end

  def filter_by_language
    ["(languages IS NULL OR languages = '' OR languages LIKE ?)", val(:preferred_language)]
  end

  def filter_by_age_start
    ['(age_start IS NULL OR age_start <= ?)', @person.years]
  end

  def filter_by_age_finish
    ['(age_finish IS NULL OR age_finish >= ?)', @person.years]
  end

  def val(method)
    value = @person.send(method)
    value = '_nil' if value.blank? && method == :gender
    value.present? ? "%#{value}%" : nil
  end

end
