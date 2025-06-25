#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe Synchronize::Mailchimp::Client do
  let(:member_fields) { Synchronize::Mailchimp::Synchronizator.member_fields }

  let(:person) { people(:admin) }
  let(:client) { described_class.new(MailingList.new, member_fields: member_fields) }

  it "language is missing if not set on person" do
    person.update(preferred_language: nil)
    body = client.subscriber_body(person)
    expect(body).not_to have_key(:language)
  end

  it "language is present if set on person" do
    person.update!(preferred_language: "de")
    body = client.subscriber_body(person)
    expect(body[:language]).to eq "de"
  end
end
