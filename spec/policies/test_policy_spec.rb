# frozen_string_literal: true

require "rails_helper"

RSpec.describe TestPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:other_teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: admin) }
  let(:test_record) { create(:test, text: text, created_by: teacher) }

  describe "管理者の場合" do
    subject { described_class.new(admin, test_record) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:take) }
    it { is_expected.to permit_action(:submit) }
    it { is_expected.to permit_action(:result) }
  end

  describe "教師（テスト作成者）の場合" do
    subject { described_class.new(teacher, test_record) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:take) }
    it { is_expected.to permit_action(:submit) }
    it { is_expected.to permit_action(:result) }
  end

  describe "教師（別のテスト）の場合" do
    subject { described_class.new(other_teacher, test_record) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "学習者の場合" do
    subject { described_class.new(learner, test_record) }

    context "テキストがアサインされている場合" do
      before do
        create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher)
      end

      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.to permit_action(:take) }
      it { is_expected.to permit_action(:submit) }
      it { is_expected.to permit_action(:result) }
    end

    context "テキストがアサインされていない場合" do
      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:take) }
      it { is_expected.not_to permit_action(:submit) }
      # result?は学習者なら常に許可（提出の有無はコントローラーで確認）
      it { is_expected.to permit_action(:result) }
    end
  end

  describe "Scope" do
    let!(:teacher_test) { create(:test, text: text, created_by: teacher) }
    let!(:other_test) { create(:test, text: text, created_by: other_teacher) }

    it "管理者は全テストを取得できる" do
      scope = described_class::Scope.new(admin, Test.all).resolve
      expect(scope).to include(teacher_test, other_test)
    end

    it "教師は自分のテストのみ取得できる" do
      scope = described_class::Scope.new(teacher, Test.all).resolve
      expect(scope).to include(teacher_test)
      expect(scope).not_to include(other_test)
    end

    it "学習者はテストを取得できない" do
      scope = described_class::Scope.new(learner, Test.all).resolve
      expect(scope).to be_empty
    end
  end
end
