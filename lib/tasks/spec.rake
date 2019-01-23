# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


if Rake::Task.task_defined?('spec:features')
  # we DO have feature specs in this wagon.
  Rake::Task['spec:features'].actions.clear
  namespace :spec do
    RSpec::Core::RakeTask.new(:features) do |t|
      t.pattern = './spec/features/**/*_spec.rb'
      t.rspec_opts = '--tag type:feature'
    end

    task all: ['spec:features', 'spec']
  end

else
  # we do NOT have feature specs in this wagon.
  namespace :spec do
    task all: 'spec'
  end
end
