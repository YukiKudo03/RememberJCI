# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:other_teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:group) { create(:group, created_by: teacher) }

  describe "管理者の場合" do
    subject { described_class.new(admin, group) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "教師（グループ作成者）の場合" do
    subject { described_class.new(teacher, group) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "教師（別のグループ）の場合" do
    subject { described_class.new(other_teacher, group) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "学習者の場合" do
    subject { described_class.new(learner, group) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "Scope" do
    let!(:teacher_group) { create(:group, created_by: teacher) }
    let!(:other_group) { create(:group, created_by: other_teacher) }

    it "管理者は全グループを取得できる" do
      scope = described_class::Scope.new(admin, Group.all).resolve
      expect(scope).to include(teacher_group, other_group)
    end

    it "教師は自分のグループのみ取得できる" do
      scope = described_class::Scope.new(teacher, Group.all).resolve
      expect(scope).to include(teacher_group)
      expect(scope).not_to include(other_group)
    end

    it "学習者はグループを取得できない" do
      scope = described_class::Scope.new(learner, Group.all).resolve
      expect(scope).to be_empty
    end
  end
end
