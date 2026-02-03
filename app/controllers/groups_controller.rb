# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # Override ApplicationController's redirect behavior for API-like responses
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    authorize Group
    @groups = policy_scope(Group)
  end

  def show
    authorize @group
  end

  def new
    authorize Group
    @group = Group.new
  end

  def create
    authorize Group
    @group = Group.new(group_params)
    @group.created_by = current_user
    if @group.save
      redirect_to groups_path, notice: "グループを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @group
  end

  def update
    authorize @group
    if @group.update(group_params)
      redirect_to groups_path, notice: "グループを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @group
    @group.destroy
    redirect_to groups_path, notice: "グループを削除しました"
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end

  def user_not_authorized
    render plain: "Forbidden", status: :forbidden
  end
end
