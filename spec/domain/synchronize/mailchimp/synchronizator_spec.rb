require 'spec_helper'

describe Synchronize::Mailchimp::Synchronizator do

  it '.merge_fields includes language' do
    expect(described_class.merge_fields).to have(1).item
    expect(described_class.merge_fields.first.first).to eq 'Gender'
  end

end
