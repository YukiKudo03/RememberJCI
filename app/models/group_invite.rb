# frozen_string_literal: true

# GroupInvite: tokenized invitation links for group membership.
#
# Lifecycle:
#
#   active ──┬── expires_at reached ──► expired
#            ├── revoked_at set        ──► revoked
#            └── uses_count == max_uses ─► exhausted
#
# `active?` is derived (not a column) from the combination of those three checks.
# Status badges in the UI render off `status_for_display` which picks the first
# non-active condition that matched (precedence: revoked > expired > exhausted).
#
# Consumption is atomic: `consume!` uses a single UPDATE with all four guards in
# the WHERE clause so concurrent accepts cannot over-consume or accept a
# just-revoked/just-expired invite.
class GroupInvite < ApplicationRecord
  belongs_to :group
  belongs_to :created_by, class_name: "User"

  has_secure_token :token, length: 32

  validates :expires_at, presence: true
  validates :max_uses, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :uses_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :not_revoked, -> { where(revoked_at: nil) }
  scope :not_expired, -> { where("expires_at > ?", Time.current) }
  scope :not_exhausted, -> { where("uses_count < max_uses") }
  scope :active, -> { not_revoked.not_expired.not_exhausted }
  scope :revoked, -> { where.not(revoked_at: nil) }
  scope :expired, -> { not_revoked.where("expires_at <= ?", Time.current) }
  scope :exhausted, -> { not_revoked.not_expired.where("uses_count >= max_uses") }

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def exhausted?
    uses_count >= max_uses
  end

  def active?
    !revoked? && !expired? && !exhausted?
  end

  # One of: :active, :revoked, :expired, :exhausted
  # Precedence for display: revoked > expired > exhausted > active
  def status_for_display
    return :revoked if revoked?
    return :expired if expired?
    return :exhausted if exhausted?
    :active
  end

  # Atomic consume: increments uses_count by 1 if and only if the invite is
  # still active. Returns true on success, false if the invite became inactive
  # between the caller reading and this call (lost race, already exhausted,
  # just revoked, just expired).
  #
  # Must be paired with a membership create on the same transaction at call site.
  def consume!
    updated = self.class
                  .where(id: id, revoked_at: nil)
                  .where("expires_at > ?", Time.current)
                  .where("uses_count < max_uses")
                  .update_all("uses_count = uses_count + 1, updated_at = NOW()")
    reload if updated == 1
    updated == 1
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
