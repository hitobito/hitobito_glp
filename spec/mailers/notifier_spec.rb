require 'spec_helper'

describe Notifier do

  context :mitglied_joined_monitoring do
    let(:role) { roles(:mitglied) }
    let(:person) { role.person }

    subject { Notifier.mitglied_joined_monitoring(role.person, role.to_s, role.person.email) }

    it 'does not fail if preferred_language language is nil' do
      person.update(preferred_language: nil)
      expect(subject.subject).to eq 'Achtung: Neues Mitglied'
      expect(subject.body).to match %r{Ein neues Mitglied hat sich registriert}
      expect(subject.body).to match %r{Sprache:\s+}
    end

    it 'includes preferred_language language in email body' do
      person.update(preferred_language: :de)
      expect(subject.subject).to eq 'Achtung: Neues Mitglied'
      expect(subject.body).to match %r{Ein neues Mitglied hat sich registriert}
      expect(subject.body).to match %r{Sprache:\s+Deutsch}
    end
  end

  context :mitglied_joined do
    let(:role) { roles(:mitglied) }
    let(:person) { role.person }

    subject { Notifier.mitglied_joined(role.person, role.person.email) }

    it 'includes preferred_language language in email body' do
      person.update(preferred_language: :de)
      expect(subject.subject).to eq 'Achtung: Neues Mitglied.'
      expect(subject.body).to match %r{Ein neues Mitglied hat sich registriert}
      expect(subject.body).to match %r{Sprache:\s+Deutsch}
    end
  end

end
