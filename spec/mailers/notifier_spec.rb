#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe NotifierMailer do
  let(:jglp) { false }

  context :mitglied_joined_monitoring do
    let(:person) { Person.new(email: "me@example.com", first_name: "Gerd", last_name: "Gärtner") }

    subject { NotifierMailer.mitglied_joined_monitoring(person, role, person.email, jglp) }

    describe "role Mitglied" do
      let(:role) { "Mitglied" }

      it "does not fail if preferred_language language is nil" do
        expect(subject.subject).to eq "Achtung: Neues Mitglied"
        expect(subject.body).to match %r{Ein neues Mitglied hat sich registriert}
        expect(subject.body).to match %r{Sprache:\s+}
        expect(subject.body).to match %r{Gerd}
        expect(subject.body).to match %r{Gärtner}
      end

      it "includes preferred_language language in email body" do
        person.preferred_language = "de"
        expect(subject.subject).to eq "Achtung: Neues Mitglied"
        expect(subject.body).to match %r{Ein neues Mitglied hat sich registriert}
        expect(subject.body).to match %r{Sprache:\s+Deutsch}
      end
    end

    describe "role Sympathisant" do
      let(:role) { "Sympathisant" }

      it "has gender neutral subject" do
        expect(subject.subject).to eq "Achtung: Neue/r Sympathisant/in"
      end
    end

    describe "role Medien_und_dritte" do
      let(:role) { "Medien_und_dritte" }

      it "has translated Role" do
        expect(subject.body).to match(/Medien &amp; Dritte/)
      end
    end
  end

  context :mitglied_joined do
    let(:role) { roles(:mitglied) }
    let(:person) { role.person }

    subject { NotifierMailer.mitglied_joined(role.person, role.person.email, jglp) }

    it "includes preferred_language language in email body" do
      person.update(preferred_language: :de)
      expect(subject.subject).to eq "Achtung: Neues Mitglied."
      expect(subject.body).to match %r{Ein neues Mitglied hat sich registriert}
      expect(subject.body).to match %r{Sprache:\s+Deutsch}
    end
  end
end
