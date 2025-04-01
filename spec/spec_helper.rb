# encoding: utf-8

#  Copyright (c) 2012-2024, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

ENV['RAILS_STRUCTURED_ADDRESSES'] = '1'
ENV['RAILS_ADDRESS_MIGRATION'] = '0'

load File.expand_path('../../app_root.rb', __FILE__)
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require File.join(ENV['APP_ROOT'], 'spec', 'spec_helper.rb')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[HitobitoGlp::Wagon.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = [File.expand_path('../fixtures', __FILE__)]
end
