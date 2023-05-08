# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


require 'rack/cors'

module HitobitoGlp
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[
      #{config.root}/app/abilities
      #{config.root}/app/domain
      #{config.root}/app/jobs
    ]

    config.to_prepare do # rubocop:disable Metrics/BlockLength
      Person.include Glp::Person
      Group.include Glp::Group
      
      # Skips paper_trail for this role type
      PaperTrail.request.disable_model(Group::Spender::Spender)

      PersonDecorator.include Glp::PersonDecorator
      GroupDecorator.prepend Glp::GroupDecorator

      PeopleController.include Glp::PeopleController
      GroupsController.permitted_attrs += [:zip_codes]
      Person::HistoryController.prepend Glp::Person::HistoryController

      GroupAbility.include Glp::GroupAbility
      PersonAbility.include Glp::PersonAbility
      RoleAbility.include Glp::RoleAbility
      EventAbility.include Glp::EventAbility
      Event::ParticipationAbility.include Glp::Event::ParticipationAbility
      MailingListAbility.include Glp::MailingListAbility
      SubscriptionAbility.include Glp::SubscriptionAbility
      PeopleFilterAbility.include Glp::PeopleFilterAbility
      ServiceTokenAbility.include Glp::ServiceTokenAbility

      PersonReadables.include Glp::PersonReadables
      PersonReadables.same_layer_permissions += [:financials]

      MailingList.include Glp::MailingList
      Person::Subscriptions.prepend Glp::Person::Subscriptions

      Sheet::Base.prepend Glp::Sheet::Base

      ApplicationMailer.send :layout, 'mailer'

      FilterNavigation::People.prepend Glp::FilterNavigation::People

      Role::Permissions << :financials << :create_spendenverwalter

      AbilityDsl::UserContext::LAYER_PERMISSIONS += [:financials, :create_spendenverwalter]
      AbilityDsl::UserContext::GROUP_PERMISSIONS += [:financials, :create_spendenverwalter]

      # TODO: maybe better additional_merge fields, code gets execute on every code reload
      Synchronize::Mailchimp::Synchronizator.member_fields = [
        [:language, ->(p) { p.preferred_language }]
      ]

      # Main navigation
      admin = NavigationHelper::MAIN.find { |entry| entry[:label] == :admin }
      admin[:active_for].append('external_forms')
      admin[:if] = ->(_) { can?(:manage_global, LabelFormat) }
    end

    initializer 'glp.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
      ActiveSupport::Inflector.inflections do |inflect|
        # inflect.irregular 'census', 'censuses'
      end
      Rails.application.config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins ['http://localhost:4000',
                   'https://grunliberale.ch',
                   'https://vertliberaux.ch',
                   'https://verdiliberali.ch',
                   'https://be.grunliberale.ch',
                   'https://gruenliberale.mironet.ch',
                   'https://www.bennoscherrer.ch/',
                   'http://liste-6.ch/',
                   'http://markusstadler.ch/',
                   'http://tianamoser.ch/',
                   'http://verenadiener.ch/',
                   'http://greenliberals.ch/',
                   /^https:\/\/(.*?)\.grunliberale\.ch$/,
                   /^https:\/\/(.*?)\.vertliberaux\.ch$/,
                   /^https:\/\/(.*?)\.verdiliberali\.ch$/]
          resource '*', headers: :any, methods: [:get, :post, :options]
        end
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
