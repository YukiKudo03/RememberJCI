# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupInvitePolicy, type: :policy do
  let(:owner)    { create(:user, :teacher) }
  let(:other)    { create(:user, :teacher) }
  let(:admin)    { create(:user, :admin) }
  let(:learner)  { create(:user, :learner) }
  let(:group)    { create(:group, created_by: owner) }
  let(:invite)   { create(:group_invite, group: group, created_by: owner) }

  describe "group-level admin actions (index / new / create)" do
    # These are authorized against a Group record in the controller, so we
    # pass a Group to the policy here rather than an invite.
    subject { described_class.new(user, group) }

    context "as admin" do
      let(:user) { admin }
      it { is_expected.to permit_actions(%i[index new create]) }
    end

    context "as group owner (teacher who created the group)" do
      let(:user) { owner }
      it { is_expected.to permit_actions(%i[index new create]) }
    end

    context "as a teacher who doesn't own the group" do
      let(:user) { other }
      it { is_expected.to forbid_actions(%i[index new create]) }
    end

    context "as a learner" do
      let(:user) { learner }
      it { is_expected.to forbid_actions(%i[index new create]) }
    end
  end

  describe "invite-level actions (destroy)" do
    subject { described_class.new(user, invite) }

    context "as admin" do
      let(:user) { admin }
      it { is_expected.to permit_action(:destroy) }
    end

    context "as group owner" do
      let(:user) { owner }
      it { is_expected.to permit_action(:destroy) }
    end

    context "as a different teacher" do
      let(:user) { other }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a learner" do
      let(:user) { learner }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "Scope" do
    let!(:owned_group)    { create(:group, created_by: owner) }
    let!(:unowned_group)  { create(:group, created_by: other) }
    let!(:owned_invite)   { create(:group_invite, group: owned_group, created_by: owner) }
    let!(:unowned_invite) { create(:group_invite, group: unowned_group, created_by: other) }

    it "admin sees all invites" do
      scope = described_class::Scope.new(admin, GroupInvite).resolve
      expect(scope).to contain_exactly(owned_invite, unowned_invite)
    end

    it "owner sees only invites for their groups" do
      scope = described_class::Scope.new(owner, GroupInvite).resolve
      expect(scope).to contain_exactly(owned_invite)
    end

    it "unrelated teacher sees none" do
      scope = described_class::Scope.new(create(:user, :teacher), GroupInvite).resolve
      expect(scope).to be_empty
    end

    it "learner sees none" do
      scope = described_class::Scope.new(learner, GroupInvite).resolve
      expect(scope).to be_empty
    end
  end
end
