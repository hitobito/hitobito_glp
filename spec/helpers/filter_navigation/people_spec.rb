# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe 'FilterNavigation::People' do

  let(:template) do
    double(:template).tap do |t|
      allow(t).to receive(:url_options).and_return({ locale: 'de' })
      expect(t).to receive(:can?).and_return(true)
      allow(t).to receive(:current_user).and_return(people(:admin))
      t.extend ActionView::Helpers::UrlHelper
      t.extend ActionView::Helpers::TagHelper
      t.extend Rails.application.routes.url_helpers
    end
  end

  let(:filter)      { double("filter").as_null_object }
  let(:navigation)  { FilterNavigation::People.new(template, group.decorate, filter) }
  let(:main_items)  { Capybara::Node::Simple.new(navigation.main_items.join) }
  let(:dropdown)    { navigation.dropdown.items }


  def item(name, regex)
    Dropdown::Item.new(name, path(name, regex))
  end

  def path(name, regex)
    types = Role.all_types.select { |type| type.to_s =~ regex }
    role_type_ids = types.collect(&:id).join(Person::Filter::Base::ID_URL_SEPARATOR)
    template.group_people_path(group.layer_group, filters: { role: { role_type_ids:  role_type_ids } }, name: name, range: 'deep')
  end

  context 'Group::Root' do
    let(:group) { groups(:root) }

    it 'has link for Mitglieder im Bund' do
      expect(main_items).to have_link 'Mitglieder im Bund (1)', href: path('Mitglieder im Bund', /Zugeordnete::Mitglied$/)
    end

    it 'counts Mitglieder from lower layers' do
      bezirk = Fabricate(Group::Bezirk.sti_name, name: 'Bern Stadt', parent: groups(:bern))
      bezirk_zugeordnete = Fabricate(Group::BezirkZugeordnete.sti_name, name: 'Zugeordnet Stadt', parent: bezirk)
      Fabricate(Group::Bezirk::BezirkZugeordnete::Mitglied.name.to_sym, group: bezirk_zugeordnete)
      expect(main_items).to have_link 'Mitglieder im Bund (2)', href: path('Mitglieder im Bund', /Zugeordnete::Mitglied$/)
    end

    it 'dropdown has link for Sympathisanten im Bund' do
      expect(dropdown).to include item('Sympathisanten im Bund', /Zugeordnete::Sympathisant$/)
    end

    it 'dropdown has link for Mitglieder and Sympathisanten im Bund' do
      expect(dropdown).to include item('Mitglieder und Sympathisanten im Bund', /Zugeordnete::(Mitglied|Sympathisant)$/)
    end
  end

  context 'Group::Kanton' do
    let(:group) { groups(:bern) }

    it 'has link for Mitglieder im Kanton' do
      expect(main_items).to have_link 'Mitglieder im Kanton (0)', href: path('Mitglieder im Kanton', /Zugeordnete::Mitglied$/)
    end

    it 'dropdown has link for Sympathisanten im Kanton' do
      expect(dropdown).to include item('Sympathisanten im Kanton', /Zugeordnete::Sympathisant$/)
    end

    it 'dropdown has link for Mitglieder and Sympathisanten im Kanton' do
      expect(dropdown).to include item('Mitglieder und Sympathisanten im Kanton', /Zugeordnete::(Mitglied|Sympathisant)$/)
    end
  end

  context 'Group::Bezirk' do
    let(:group) { Fabricate(Group::Bezirk.sti_name, name: 'Bern Stadt', parent: groups(:bern)) }

    it 'has link for Mitglieder im Bezirk' do
      expect(main_items).to have_link 'Mitglieder im Bezirk (0)', href: path('Mitglieder im Bezirk', /Zugeordnete::Mitglied$/)
    end

    it 'dropdown has link for Sympathisanten im Bezirk' do
      expect(dropdown).to include item('Sympathisanten im Bezirk', /Zugeordnete::Sympathisant$/)
    end

    it 'dropdown has link for Mitglieder and Sympathisanten im Bezirk' do
      expect(dropdown).to include item('Mitglieder und Sympathisanten im Bezirk', /Zugeordnete::(Mitglied|Sympathisant)$/)
    end
  end

  context 'Group::Ortsektion' do
    let(:bezirk) { Fabricate(Group::Bezirk.sti_name, name: 'Bern Stadt', parent: groups(:bern)) }
    let(:group)  { Fabricate(Group::Ortsektion.sti_name, name: 'Bern Stadt', parent: bezirk) }

    it 'has link for Mitglieder im Ortsektion' do
      expect(main_items).to have_link 'Mitglieder in der Ortsektion (0)', href: path('Mitglieder in der Ortsektion', /Zugeordnete::Mitglied$/)
    end

    it 'dropdown has link for Sympathisanten im Ortsektion' do
      expect(dropdown).to include item('Sympathisanten in der Ortsektion', /Zugeordnete::Sympathisant$/)
    end

    it 'dropdown has link for Mitglieder and Sympathisanten in der Ortsektion' do
      expect(dropdown).to include item('Mitglieder und Sympathisanten in der Ortsektion', /Zugeordnete::(Mitglied|Sympathisant)$/)
    end
  end
end
