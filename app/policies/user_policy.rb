# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # Only admins can view the list of users
  def index?
    user.admin?
  end

  # Only admins can view user details
  def show?
    user.admin?
  end

  # Only admins can create users
  def create?
    user.admin?
  end

  # Only admins can update users
  def update?
    user.admin?
  end

  # Admins can destroy users, but cannot delete themselves
  def destroy?
    user.admin? && user != record
  end

  # Only admins can import users via CSV
  def import?
    user.admin?
  end

  # Only admins can create users via CSV import
  def import_create?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
