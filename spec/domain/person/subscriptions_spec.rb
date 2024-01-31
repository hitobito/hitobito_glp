#  Copyright (c) 2020, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Person::Subscriptions do

  let(:person)       { people(:admin) }
  let(:root)         { groups(:root) }
  let(:list)         { root.mailing_lists.create!(name: 'test') }

  subject { Person::Subscriptions.new(person).subscribed }

  before do
    list.subscriptions.create!(subscriber: root, role_types: ['Group::Root::Administrator'])
  end

  describe 'filter_by_language' do
    it 'is present when language is nil' do
      list.update(languages: nil)
      expect(subject).to be_present
    end

    it 'is present when language is empty string' do
      list.update(languages: '')
      expect(subject).to be_present
    end

    it 'is present when language includes person language' do
      list.update(languages: 'de,fr,it')
      expect(subject).to be_present
    end

    it 'is empty when language is different to person language' do
      list.update(languages: 'fr,it')
      expect(subject).to be_blank
    end

    it 'is empty when language is set and person has no language' do
      person.update!(preferred_language: nil)
      list.update(languages: 'de')
      expect(subject).to be_empty
    end
  end

  describe 'filter_by_gender' do
    it 'is present when gender is nil' do
      list.update(genders: nil)
      expect(subject).to be_present
    end

    it 'is present when gender is empty string' do
      list.update(genders: '')
      expect(subject).to be_present
    end

    it 'is present when gender includes person gender' do
      list.update(genders: 'm,w')
      person.update(gender: 'w')
      expect(subject).to be_present
    end

    it 'is empty when gender is different to person gender' do
      list.update(genders: 'm')
      person.update(gender: 'w')
      expect(subject).to be_empty
    end

    it 'is empty when gender is set to unknonw gender' do
      list.update(genders: :_nil)
      expect(subject).to be_empty
    end
  end

  describe 'age' do
    it 'is empty when minimum age is set and person has no birthday' do
      list.update(age_start: 30)
      expect(subject).to be_empty
    end

    it 'is empty when minimum age is set and person is too young' do
      person.update(birthday: 29.years.ago)
      list.update(age_start: 30)
      expect(subject).to be_empty
    end

    it 'is present when minimum age is set and person is old enough' do
      person.update(birthday: 29.years.ago)
      list.update(age_start: 29)
      expect(subject).to be_present
    end

    it 'is empty when maximum age is set and person is too old' do
      person.update(birthday: 29.years.ago)
      list.update(age_finish: 29)
      expect(subject).to be_present
    end
  end

  it 'always includes person if included directly' do
    list.update(languages: 'fr')
    list.subscriptions.create!(subscriber: person)
    expect(subject).to be_present
  end
end
