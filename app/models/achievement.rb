# frozen_string_literal: true

class Achievement < ApplicationRecord
  BADGE_TYPES = %w[all_texts_mastered].freeze

  belongs_to :user

  validates :badge_type, presence: true, inclusion: { in: BADGE_TYPES }
  validates :badge_type, uniqueness: { scope: :user_id }
  validates :awarded_at, presence: true

  scope :for_badge, ->(type) { where(badge_type: type) }
end
