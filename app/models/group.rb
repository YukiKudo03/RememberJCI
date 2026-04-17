# app/models/group.rb
#
# Membership is guarded by a composite unique index on
# group_memberships(user_id, group_id). `add_member` uses find_or_create_by!
# so two concurrent accepts can't both create a row — if they race past the
# app-level find, the second insert fails at the DB and is rescued back into
# a find.
class Group < ApplicationRecord
  # Associations
  belongs_to :created_by, class_name: "User"
  has_many :group_members, class_name: "GroupMembership", dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_many :assignments, dependent: :destroy
  has_many :invites, class_name: "GroupInvite", dependent: :destroy

  # Validations
  validates :name, presence: true

  # Idempotent: returns the GroupMembership whether it was just created or
  # already existed. Safe under concurrency thanks to the DB unique index.
  def add_member(user)
    group_members.find_or_create_by!(user: user)
  rescue ActiveRecord::RecordNotUnique
    group_members.find_by!(user: user)
  end
end
