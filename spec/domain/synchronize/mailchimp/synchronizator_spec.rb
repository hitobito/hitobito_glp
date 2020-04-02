# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require 'spec_helper'

describe Synchronize::Mailchimp::Synchronizator do

  it '.merge_fields includes language' do
    expect(described_class.merge_fields).to have(1).item
    expect(described_class.merge_fields.first.first).to eq 'Gender'
  end

end
