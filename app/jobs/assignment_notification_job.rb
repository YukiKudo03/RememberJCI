# frozen_string_literal: true

# AssignmentNotificationJob - アサインメント作成時に通知メールを送信
class AssignmentNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    return unless assignment

    recipients = determine_recipients(assignment)
    recipients.each do |user|
      AssignmentMailer.new_assignment(assignment, user).deliver_later
    end
  end

  private

  def determine_recipients(assignment)
    if assignment.user.present?
      [assignment.user]
    elsif assignment.group.present?
      assignment.group.members.to_a
    else
      []
    end
  end
end
