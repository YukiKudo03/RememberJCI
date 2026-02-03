# AssignmentMailer - アサインメント通知メール
class AssignmentMailer < ApplicationMailer
  def new_assignment(assignment, user)
    @assignment = assignment
    @user = user
    @text = assignment.text
    @assigned_by = assignment.assigned_by

    mail(
      to: user.email,
      subject: "【RememberIt】新しいテキストがアサインされました"
    )
  end
end
