#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

Fabrication.configure do |config|
  config.fabricator_path = ["spec/fabricators",
    "../hitobito_glp/spec/fabricators"]
  config.path_prefix = Rails.root
end
