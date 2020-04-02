require 'spec_helper'

describe Synchronize::Mailchimp::Client do
  let(:member_fields) { Synchronize::Mailchimp::Synchronizator.member_fields }

  let(:person)       { people(:admin) }
  let(:client)       { described_class.new(MailingList.new, member_fields: member_fields) }

  it 'language is missing if not set on person' do
    person.update(preferred_language: nil)
    body = client.subscriber_body(person)
    expect(body).not_to have_key(:language)
  end

  it 'language is present if set on person' do
    person.update!(preferred_language: 'de')
    body = client.subscriber_body(person)
    expect(body[:language]).to eq 'de'
  end
end
