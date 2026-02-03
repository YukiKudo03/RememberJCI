# frozen_string_literal: true

class GroupMembersController < ApplicationController
  skip_after_action :verify_policy_scoped

  before_action :set_group
  before_action :authorize_group

  # Override ApplicationController's redirect behavior for API-like responses
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def create
    user = User.find(params[:user_id])
    @group.add_member(user)
    redirect_to group_path(@group), notice: "メンバーを追加しました"
  end

  def destroy
    membership = @group.group_members.find(params[:id])
    membership.destroy
    redirect_to group_path(@group), notice: "メンバーを削除しました"
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def authorize_group
    authorize @group, :update?
  end

  def user_not_authorized
    render plain: "Forbidden", status: :forbidden
  end
end
