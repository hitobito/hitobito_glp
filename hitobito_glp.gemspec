# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your wagon's version:
require "hitobito_glp/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "hitobito_glp"
  s.version = HitobitoGlp::VERSION
  s.authors = ["Andreas Maierhofer"]
  s.email = ["maierhofer@puzzle.ch"]
  s.summary = "Glp organization specific features"
  s.description = "Glp organization specific features"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]

  s.add_runtime_dependency "aws-sdk-s3"
  s.add_runtime_dependency "rack-cors"

  s.metadata["rubygems_mfa_required"] = "true"
end
