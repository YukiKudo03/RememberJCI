# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:other_teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: admin) }
  let(:group) { create(:group, created_by: teacher) }
  let(:assignment) { create(:assignment, :to_group, group: group, text: text, assigned_by: teacher) }

  describe "管理者の場合" do
    subject { described_class.new(admin, assignment) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "教師（アサインメント作成者）の場合" do
    subject { described_class.new(teacher, assignment) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "教師（別のアサインメント）の場合" do
    subject { described_class.new(other_teacher, assignment) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "学習者の場合" do
    subject { described_class.new(learner, assignment) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "Scope" do
    let!(:teacher_assignment) { create(:assignment, :to_group, group: group, text: text, assigned_by: teacher) }
    let!(:other_group) { create(:group, created_by: other_teacher) }
    let!(:other_assignment) { create(:assignment, :to_group, group: other_group, text: text, assigned_by: other_teacher) }

    it "管理者は全アサインメントを取得できる" do
      scope = described_class::Scope.new(admin, Assignment.all).resolve
      expect(scope).to include(teacher_assignment, other_assignment)
    end

    it "教師は自分のアサインメントのみ取得できる" do
      scope = described_class::Scope.new(teacher, Assignment.all).resolve
      expect(scope).to include(teacher_assignment)
      expect(scope).not_to include(other_assignment)
    end
  end
end
