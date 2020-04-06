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
      t.extend ActionView::Helpers::UrlHelper
      t.extend ActionView::Helpers::TagHelper
      t.extend Rails.application.routes.url_helpers
    end
  end

  let(:filter)     { double("filter").as_null_object }
  let(:navigation) { FilterNavigation::People.new(template, group.decorate, filter) }

  let(:filter_params) do
    { filters: { role: { role_type_ids: '10-42-59-80' } }, range: 'deep' }
  end


  context 'Group::Kanton' do
    before do
      Fabricate(Group::Kanton::KantonZugeordnete::Mitglied.name.to_sym, group: groups(:bern_zugeordnete))
      allow(template).to receive(:current_user).and_return(people(:admin))
    end

    let(:dom)    { Capybara::Node::Simple.new(navigation.main_items.join) }

    let(:label)  { 'Mitglieder im Kanton (1)' }
    let(:params) { filter_params.merge(name: 'Mitglieder im Kanton') }
    let(:kanton) { groups(:bern) }
    let(:bezirk) { Fabricate(Group::Bezirk.sti_name, name: 'Bern Stadt', parent: kanton) }


    context 'Group::Kanton' do
      let(:group) { kanton }

      it 'has link for Mitglieder im Kanton' do
        expect(navigation.main_items).to have(2).items
        expect(dom).to have_link label, href: template.group_people_path(kanton, params)
      end
    end

    context 'Group::KantonKontakte' do
      let(:group) { groups(:bern_kontakte) }

      it 'has link for Mitglieder im Kanton' do
        expect(navigation.main_items).to have(2).items
        expect(dom).to have_link label, href: template.group_people_path(kanton, params)
      end
    end

    context 'Group::Bezirk' do
      let(:group) { bezirk }

      it 'has link for Mitglieder im Kanton' do
        expect(navigation.main_items).to have(2).items
        expect(dom).to have_link label, href: template.group_people_path(kanton, params)
      end
    end

    context 'Group::OrtSektion' do
      let(:group) { Fabricate(Group::Ortsektion.sti_name, name: 'Bern Stadt', parent: bezirk) }

      it 'has link for Mitglieder im Kanton' do
        expect(navigation.main_items).to have(2).items
        expect(dom).to have_link label, href: template.group_people_path(kanton, params)
      end
    end

    context 'Bezirk::Zugeordnete' do
      before do
        Fabricate(Group::Bezirk::BezirkZugeordnete::Mitglied.name.to_sym, group: bezirk_zugeordnete)
      end

      let(:bezirk_zugeordnete) { Fabricate(Group::BezirkZugeordnete.sti_name, name: 'Zugeordnet Stadt', parent: bezirk) }
      let(:label)              { 'Mitglieder im Kanton (2)' }

      context 'Group::KantonKontakte' do
        let(:group) { groups(:bern_kontakte) }

        it 'has link for Mitglieder im Kanton' do
          expect(navigation.main_items).to have(2).items
          expect(dom).to have_link label, href: template.group_people_path(kanton, params)
        end
      end

      context 'Group::Bezirk' do
        let(:group) { bezirk }

        it 'has link for Mitglieder im Kanton' do
          expect(navigation.main_items).to have(2).items
          expect(dom).to have_link label, href: template.group_people_path(kanton, params)
        end
      end
    end
  end

  context 'others' do
    let(:root)  { groups(:root) }

    context 'root' do
      let(:group) { root }
      it 'has only link for Mitglieder' do
        expect(navigation.main_items).to have(1).item
      end
    end
    context 'foreigners' do
      let(:group)  { Fabricate(Group::Kanton.sti_name, parent: root, name: 'Ausland', zip_codes: SortingHat::FOREIGN_ZIP_CODE) }

      it 'has only link for Mitglieder' do
        expect(navigation.main_items).to have(1).item
      end
    end

    context 'jGLP' do
      let(:group)  { Fabricate(Group::Kanton.sti_name, parent: root, name: 'Ausland', zip_codes: SortingHat::JGLP_ZIP_CODE) }

      it 'has only link for Mitglieder' do
        expect(navigation.main_items).to have(1).item
      end
    end
  end
end
