# Preview all emails at http://localhost:3000/rails/mailers/assignment_mailer
class AssignmentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/assignment_mailer/new_assignment
  def new_assignment
    assignment = Assignment.first || build_sample_assignment
    user = assignment.user || User.first

    AssignmentMailer.new_assignment(assignment, user)
  end

  private

  def build_sample_assignment
    # 実際のレコードがない場合のサンプル用
    teacher = User.find_by(role: :teacher) || User.first
    text = Text.first || Text.new(title: "サンプルテキスト", content: "サンプル内容")

    Assignment.new(
      text: text,
      user: User.first,
      assigned_by: teacher,
      deadline: 1.week.from_now
    )
  end
end
