#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

describe SortingHat do
  it ".locked? is true for top level foreign and jglp groups" do
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: SortingHat::FOREIGN_ZIP_CODE))).to eq true
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: SortingHat::JGLP_ZIP_CODE))).to eq true
    expect(SortingHat.locked?(Group::Kanton.new(zip_codes: "other"))).to eq false
  end
end
