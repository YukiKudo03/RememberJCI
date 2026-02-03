# frozen_string_literal: true

class TextPolicy < ApplicationPolicy
  # Only admins can view the list of texts
  def index?
    user.admin?
  end

  # Only admins can view text details
  def show?
    user.admin?
  end

  # Only admins can create texts
  def create?
    user.admin?
  end

  # Only admins can update texts
  def update?
    user.admin?
  end

  # Only admins can destroy texts
  def destroy?
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
