# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:other_user) { create(:user) }

  describe "管理者の場合" do
    subject { described_class.new(admin, other_user) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "管理者が自分自身を削除しようとした場合" do
    subject { described_class.new(admin, admin) }

    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "教師の場合" do
    subject { described_class.new(teacher, other_user) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
  end

  describe "学習者の場合" do
    subject { described_class.new(learner, other_user) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
  end
end
