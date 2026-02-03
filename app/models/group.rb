# app/models/group.rb
class Group < ApplicationRecord
  # Associations
  belongs_to :created_by, class_name: "User"
  has_many :group_members, class_name: "GroupMembership", dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_many :assignments, dependent: :destroy

  # Validations
  validates :name, presence: true

  # Add a user to the group if not already a member
  def add_member(user)
    members << user unless members.include?(user)
  end
end
