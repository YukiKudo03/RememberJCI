# frozen_string_literal: true

# Small status pill used by invite index rows. Color + text only — no icons,
# no shadows. Text is the source of truth so the badge is legible without
# color (color-blindness friendly).
#
# Variants map to GroupInvite statuses:
#   :active    → green
#   :expired   → gray
#   :revoked   → gray with strikethrough
#   :exhausted → gray
class StatusBadgeComponent < ApplicationComponent
  VARIANTS = {
    active:    { classes: "bg-green-100 text-green-800",                    label_key: "group_invites.statuses.active" },
    expired:   { classes: "bg-gray-100 text-gray-600",                      label_key: "group_invites.statuses.expired" },
    revoked:   { classes: "bg-gray-100 text-gray-500 line-through",         label_key: "group_invites.statuses.revoked" },
    exhausted: { classes: "bg-gray-100 text-gray-600",                      label_key: "group_invites.statuses.exhausted" }
  }.freeze

  def initialize(status:)
    @status = status.to_sym
    raise ArgumentError, "Unknown status: #{@status}" unless VARIANTS.key?(@status)
  end

  def classes
    VARIANTS[@status][:classes]
  end

  def label
    I18n.t(VARIANTS[@status][:label_key])
  end
end
