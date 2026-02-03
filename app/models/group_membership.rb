# Stub model for association testing - will be fully implemented later
class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id, message: "は既にこのグループのメンバーです" }
end
