# encoding: utf-8
require 'rack/cors'

module HitobitoGlp
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W( #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
    )

    config.to_prepare do
      Person.send           :include, Glp::Person
      Group.send            :include, Glp::Group

      PeopleController.send :include, Glp::PeopleController
      GroupsController.permitted_attrs += [:zip_codes]

      GroupAbility.send     :include, Glp::GroupAbility

      MailingList.send           :include, Glp::MailingList

      Devise::SessionsController.send(:include, Glp::Devise::SessionsController)

      ApplicationMailer.send :layout, 'mailer'
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
                   'http://greenliberals.ch/'
                 ]
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
