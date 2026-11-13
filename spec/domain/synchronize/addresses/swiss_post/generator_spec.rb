# frozen_string_literal: true

#  Copyright (c) 2026, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe Synchronize::Addresses::SwissPost::Generator do
  it "does not send address_addition to the post" do
    expect(described_class.fields[:AddressAddition_in]).to be_nil
  end
end
