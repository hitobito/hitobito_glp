$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_glp/version'


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_glp'
  s.version     = HitobitoGlp::VERSION
  s.authors     = ['Andreas Maierhofer']
  s.email       = ['maierhofer@puzzle.ch']
  s.summary     = 'Glp organization specific features'
  s.description = 'Glp organization specific features'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']
  # rubocop:enable SingleSpaceBeforeFirstArg

  s.add_runtime_dependency 'aws-sdk'
  s.add_runtime_dependency 'dotenv-rails'
  s.add_runtime_dependency 'rack-cors'
  s.add_runtime_dependency 'twilio-ruby'
end
