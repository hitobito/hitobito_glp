#  Copyright (c) 2026, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

require "spec_helper"

describe "External form", js: true do
  it "shows success message after form is hidden" do
    visit external_forms_test_path(role: "sympathisant")

    fill_in "first_name", with: "Tom"
    fill_in "last_name", with: "Tester"
    fill_in "email", with: "tom.tester@example.com"
    check "terms_and_conditions"
    click_button "Senden"

    expect(page).to have_css("#hitobito-external-form-message.success")
    expect(page).to have_no_css("form")
  end

  it "shows submit error below form" do
    visit external_forms_test_path(role: "sympathisant")

    fill_in "first_name", with: "Tom"
    fill_in "last_name", with: "Taken"
    fill_in "email", with: people(:leader).email
    check "terms_and_conditions"
    click_button "Senden"

    expect(page).to have_css("form ~ #hitobito-external-form-message.error",
      text: "Deine E-Mail-Adresse ist leider schon vergeben")
  end
end
