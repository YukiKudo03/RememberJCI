# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  # Admins and teachers can view the list of groups
  def index?
    user.admin? || user.teacher?
  end

  # Admins can view any group, teachers can view their own groups
  def show?
    user.admin? || owner?
  end

  # Admins and teachers can create groups
  def create?
    user.admin? || user.teacher?
  end

  # Admins can update any group, teachers can update their own groups
  def update?
    user.admin? || owner?
  end

  # Admins can destroy any group, teachers can destroy their own groups
  def destroy?
    user.admin? || owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.teacher?
        scope.where(created_by: user)
      else
        scope.none
      end
    end
  end

  private

  # Check if the user is the owner of the group
  def owner?
    record.created_by_id == user.id
  end
end
