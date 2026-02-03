# frozen_string_literal: true

class DashboardController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    case current_user.role
    when "learner"
      @assignments = Assignment.includes(:text).where(user: current_user)
    when "teacher"
      @groups = Group.where(created_by: current_user)
    when "admin"
      @statistics = load_admin_statistics
    end
  end

  private

  def load_admin_statistics
    progresses = LearningProgress.all
    submissions = TestSubmission.where.not(auto_score: nil).or(TestSubmission.where.not(manual_score: nil))

    {
      total_users: User.count,
      total_groups: Group.count,
      total_texts: Text.count,
      completion_rate: calculate_completion_rate(progresses),
      average_best_score: calculate_average_best_score(progresses),
      test_average_score: calculate_test_average_score(submissions),
      total_study_time: progresses.sum(:total_study_time),
      total_submissions: TestSubmission.count,
      inactive_users: find_inactive_users
    }
  end

  def calculate_completion_rate(progresses)
    return 0.0 if progresses.empty?

    mastered = progresses.where(current_level: 5, best_score: 100).count
    (mastered.to_f / progresses.count * 100).round(1)
  end

  def calculate_average_best_score(progresses)
    return 0.0 if progresses.empty?

    progresses.average(:best_score).to_f.round(1)
  end

  def calculate_test_average_score(graded_submissions)
    return 0.0 if graded_submissions.empty?

    scores = graded_submissions.map(&:final_score).compact
    return 0.0 if scores.empty?

    (scores.sum.to_f / scores.count).round(1)
  end

  def find_inactive_users
    cutoff = 30.days.ago

    # Learners who have not had any learning or test activity in the last 30 days
    active_via_progress = LearningProgress.where("updated_at >= ?", cutoff).select(:user_id)
    active_via_submissions = TestSubmission.where("created_at >= ?", cutoff).select(:user_id)

    User.learners
        .where("users.created_at < ?", cutoff)
        .where.not(id: active_via_progress)
        .where.not(id: active_via_submissions)
  end
end
