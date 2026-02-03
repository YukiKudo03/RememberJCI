# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:destroy]

  # Override ApplicationController's redirect behavior for API-like responses
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    authorize Assignment
    @assignments = policy_scope(Assignment).includes(:text, :user, :group, :assigned_by)
  end

  def new
    authorize Assignment
    @assignment = Assignment.new
  end

  def create
    authorize Assignment
    @assignment = Assignment.new(assignment_params)
    @assignment.assigned_by = current_user
    if @assignment.save
      AssignmentNotificationJob.perform_later(@assignment.id)
      redirect_to assignments_path, notice: "アサインメントを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @assignment
    @assignment.destroy
    redirect_to assignments_path, notice: "アサインメントを削除しました"
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:text_id, :user_id, :group_id, :deadline)
  end

  def user_not_authorized
    render plain: "Forbidden", status: :forbidden
  end
end
