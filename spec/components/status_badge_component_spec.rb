# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatusBadgeComponent, type: :component do
  it "renders the active pill with green classes and the active label" do
    render_inline(described_class.new(status: :active))
    expect(page).to have_css("span.bg-green-100.text-green-800", text: I18n.t("group_invites.statuses.active"))
  end

  it "renders the expired pill with gray classes" do
    render_inline(described_class.new(status: :expired))
    expect(page).to have_css("span.bg-gray-100.text-gray-600", text: I18n.t("group_invites.statuses.expired"))
  end

  it "renders the revoked pill with strikethrough" do
    render_inline(described_class.new(status: :revoked))
    expect(page).to have_css("span.bg-gray-100.text-gray-500.line-through", text: I18n.t("group_invites.statuses.revoked"))
  end

  it "renders the exhausted pill with gray classes" do
    render_inline(described_class.new(status: :exhausted))
    expect(page).to have_css("span.bg-gray-100.text-gray-600", text: I18n.t("group_invites.statuses.exhausted"))
  end

  it "accepts string statuses via to_sym" do
    render_inline(described_class.new(status: "active"))
    expect(page).to have_css("span.bg-green-100")
  end

  it "raises ArgumentError for an unknown status" do
    expect { described_class.new(status: :unknown) }.to raise_error(ArgumentError, /Unknown status/)
  end
end
