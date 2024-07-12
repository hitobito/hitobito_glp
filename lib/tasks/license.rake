#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

namespace :app do
  namespace :license do
    task :config do
      @licenser = Licenser.new("hitobito_glp",
        "GLP Schweiz",
        "https://github.com/hitobito/hitobito_glp")
    end
  end
end
