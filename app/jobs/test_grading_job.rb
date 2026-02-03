# frozen_string_literal: true

# TestGradingJob - テスト提出の非同期採点ジョブ
#
# 要件参照: FR-51（差分比較によるタイピングテストの自動採点）
#
# @example 非同期で採点を実行
#   TestGradingJob.perform_later(submission.id)
#
class TestGradingJob < ApplicationJob
  queue_as :grading

  # @param submission_id [Integer] 採点対象のTestSubmissionのID
  def perform(submission_id)
    return if submission_id.blank?

    submission = TestSubmission.find_by(id: submission_id)
    return unless submission

    # ScoringServiceを使用して採点
    Testing::ScoringService.new(submission: submission).grade!
  end
end
