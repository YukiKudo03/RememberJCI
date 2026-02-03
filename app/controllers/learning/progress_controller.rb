# frozen_string_literal: true

module Learning
  class ProgressController < ApplicationController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_progress, only: [:show]
    before_action :authorize_progress, only: [:show]

    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

    def index
      # Get all texts assigned to the current user
      direct_assignments = Assignment.where(user: current_user)
      group_assignments = Assignment.where(group: current_user.groups)

      text_ids = (direct_assignments + group_assignments).map(&:text_id).uniq
      @texts = Text.where(id: text_ids)

      # Get progress for each text
      @progresses = LearningProgress.where(user: current_user, text_id: text_ids)
                                    .index_by(&:text_id)

      # Calculate statistics
      @total_texts = @texts.count
      @completed_texts = @progresses.values.count(&:mastered?)
      @total_study_time = @progresses.values.sum(&:total_study_time)

      # Load achievements
      @achievements = current_user.achievements.order(awarded_at: :desc)
    end

    def show
      @text = @progress.text
    end

    private

    def set_progress
      @progress = LearningProgress.find(params[:id])
    end

    def authorize_progress
      raise Pundit::NotAuthorizedError unless @progress.user_id == current_user.id
    end

    def render_forbidden
      render plain: "Forbidden", status: :forbidden
    end
  end
end
