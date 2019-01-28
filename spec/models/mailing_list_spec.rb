# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'spec_helper'

describe MailingList do

  let(:role) { Group::RootZugeordnete::Mitglied.name.to_sym }
  let(:other_role) { Group::KantonZugeordnete::Mitglied.name.to_sym }
  let(:person) { Fabricate(role, group: groups(:root_zugeordnete)).person }
  let(:other_person) { Fabricate(other_role, group: groups(:bern_zugeordnete)).person }

  before { create_subscription(groups(:root), false, Group::RootZugeordnete::Mitglied.sti_name) }

  describe 'without filters' do
    let(:list){ Fabricate(:mailing_list, group: groups(:root)) }
    it 'has the correct people in it ' do
      expect(list.people).not_to include(other_person)
      expect(list.people).to include(person)
    end
  end

  describe 'with age filter' do
    let(:person_aged_20) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, birthday: Time.now - 20.years)).person }
    let(:person_aged_50) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, birthday: Time.now - 50.years)).person }

    describe '(age > 30)' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), age_start: 30) }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).not_to include(person)
        expect(list.people).not_to include(person_aged_20)
        expect(list.people).to include(person_aged_50)
      end

      it 'includes explicitly subscribed person even though attribute filter does not match' do
        list.subscriptions.create(subscriber: person_aged_20)
        expect(list.people).not_to include(person)
        expect(list.people).to include(person_aged_20)
      end

      it 'includes explicitly subscribed person when no attribute filter is defined' do
        list.update(age_start: nil)
        list.subscriptions.create(subscriber: person_aged_20)
        expect(list.people).to include(person_aged_20)
        expect(list.people).to include(person_aged_50)
      end

      it 'but not if subscription is for a different list' do
        other_list = Fabricate(:mailing_list, group: groups(:root))
        other_list.subscriptions.create(subscriber: person_aged_20)
        expect(list.people).not_to include(person_aged_20)
        expect(list.people).to include(person_aged_50)
      end
    end

    describe '(age < 30)' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), age_finish: 30) }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).not_to include(person)
        expect(list.people).to include(person_aged_20)
        expect(list.people).not_to include(person_aged_50)
      end
    end

    describe '(30 < age < 60)' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), age_start: 30, age_finish: 60) }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).not_to include(person)
        expect(list.people).not_to include(person_aged_20)
        expect(list.people).to include(person_aged_50)
      end
    end
  end

  describe 'with gender filter' do
    let(:person_with_unknown_gender) { Fabricate(role, group: groups(:root_zugeordnete)).person }
    let(:person_with_male_gender) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, gender: 'm')).person }
    let(:person_with_female_gender) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, gender: 'w')).person }

    describe '(genders = [])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), genders: "") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).to include(person)
        expect(list.people).to include(person_with_unknown_gender)
        expect(list.people).to include(person_with_male_gender)
        expect(list.people).to include(person_with_female_gender)
      end
    end

    describe '(genders = [m])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), genders: "m") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).not_to include(person)
        expect(list.people).not_to include(person_with_unknown_gender)
        expect(list.people).to include(person_with_male_gender)
        expect(list.people).not_to include(person_with_female_gender)
      end
    end

    describe '(genders = [m,w,_nil])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), genders: "m,w,_nil") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).to include(person)
        expect(list.people).to include(person_with_unknown_gender)
        expect(list.people).to include(person_with_male_gender)
        expect(list.people).to include(person_with_female_gender)
      end
    end

    describe '(genders = [_nil])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), genders: "_nil") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).to include(person)
        expect(list.people).to include(person_with_unknown_gender)
        expect(list.people).not_to include(person_with_male_gender)
        expect(list.people).not_to include(person_with_female_gender)
      end
    end
  end

  describe 'with language filter' do
    let(:person_preferring_german) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, preferred_language: :de)).person }
    let(:person_preferring_french) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, preferred_language: :fr)).person }
    let(:person_preferring_italian) { Fabricate(role, group: groups(:root_zugeordnete), person: Fabricate(:person, preferred_language: :it)).person }

    describe '(languages = [])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), languages: "") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).to include(person)
        expect(list.people).to include(person_preferring_german)
        expect(list.people).to include(person_preferring_french)
        expect(list.people).to include(person_preferring_italian)
      end
    end

    describe '(languages = [de])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), languages: "de") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).not_to include(person)
        expect(list.people).to include(person_preferring_german)
        expect(list.people).not_to include(person_preferring_french)
        expect(list.people).not_to include(person_preferring_italian)
      end
    end

    describe '(languages = [de,fr,it])' do
      let(:list){ Fabricate(:mailing_list, group: groups(:root), languages: "de,fr,it") }
      it 'has the correct people in it ' do
        expect(list.people).not_to include(other_person)
        expect(list.people).not_to include(person)
        expect(list.people).to include(person_preferring_german)
        expect(list.people).to include(person_preferring_french)
        expect(list.people).to include(person_preferring_italian)
      end
    end
  end

  def create_subscription(subscriber, excluded = false, *role_types)
    sub = list.subscriptions.new
    sub.subscriber = subscriber
    sub.excluded = excluded
    sub.related_role_types = role_types.collect { |t| RelatedRoleType.new(role_type: t) }
    sub.save!
    sub
  end

end
