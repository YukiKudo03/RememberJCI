# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  # Admins and teachers can view the list of assignments
  def index?
    user.admin? || user.teacher?
  end

  # Admins can view any assignment, teachers can view their own assignments
  def show?
    user.admin? || owner?
  end

  # Admins and teachers can create assignments
  def create?
    user.admin? || user.teacher?
  end

  # Admins can destroy any assignment, teachers can destroy their own assignments
  def destroy?
    user.admin? || owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.teacher?
        scope.where(assigned_by: user)
      else
        scope.none
      end
    end
  end

  private

  # Check if the user is the owner of the assignment
  def owner?
    record.assigned_by_id == user.id
  end
end
