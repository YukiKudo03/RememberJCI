# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupInvite, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_presence_of(:max_uses) }
    it { is_expected.to validate_numericality_of(:max_uses).is_greater_than(0).only_integer }
    it { is_expected.to validate_numericality_of(:uses_count).is_greater_than_or_equal_to(0).only_integer }
  end

  describe "token generation" do
    it "auto-generates a 32-char token on create" do
      invite = create(:group_invite)
      expect(invite.token).to be_present
      expect(invite.token.length).to eq(32)
    end

    it "generates unique tokens across invites" do
      tokens = 5.times.map { create(:group_invite).token }
      expect(tokens.uniq.size).to eq(5)
    end
  end

  describe "status predicates" do
    it "is active when not revoked, not expired, and not exhausted" do
      invite = build(:group_invite)
      expect(invite).to be_active
      expect(invite).not_to be_revoked
      expect(invite).not_to be_expired
      expect(invite).not_to be_exhausted
    end

    it "is expired when expires_at is in the past" do
      invite = build(:group_invite, :expired)
      expect(invite).to be_expired
      expect(invite).not_to be_active
    end

    it "is revoked when revoked_at is set" do
      invite = build(:group_invite, :revoked)
      expect(invite).to be_revoked
      expect(invite).not_to be_active
    end

    it "is exhausted when uses_count reaches max_uses" do
      invite = build(:group_invite, :exhausted)
      expect(invite).to be_exhausted
      expect(invite).not_to be_active
    end
  end

  describe "#status_for_display" do
    it "returns :revoked when revoked, even if also expired" do
      invite = build(:group_invite, :revoked, :expired)
      expect(invite.status_for_display).to eq(:revoked)
    end

    it "returns :expired when expired but not revoked" do
      invite = build(:group_invite, :expired)
      expect(invite.status_for_display).to eq(:expired)
    end

    it "returns :exhausted when exhausted but not expired or revoked" do
      invite = build(:group_invite, :exhausted)
      expect(invite.status_for_display).to eq(:exhausted)
    end

    it "returns :active when none of the inactive states apply" do
      invite = build(:group_invite)
      expect(invite.status_for_display).to eq(:active)
    end
  end

  describe "scopes" do
    let!(:active)    { create(:group_invite) }
    let!(:expired)   { create(:group_invite, :expired) }
    let!(:revoked)   { create(:group_invite, :revoked) }
    let!(:exhausted) { create(:group_invite, :exhausted) }

    it ".active returns only active invites" do
      expect(described_class.active).to contain_exactly(active)
    end

    it ".expired returns only expired (not revoked) invites" do
      expect(described_class.expired).to contain_exactly(expired)
    end

    it ".revoked returns all revoked invites regardless of other states" do
      expect(described_class.revoked).to contain_exactly(revoked)
    end

    it ".exhausted returns exhausted (not expired/revoked) invites" do
      expect(described_class.exhausted).to contain_exactly(exhausted)
    end
  end

  describe "#consume!" do
    it "increments uses_count and returns true for an active invite" do
      invite = create(:group_invite, max_uses: 3)
      expect(invite.consume!).to be(true)
      expect(invite.reload.uses_count).to eq(1)
    end

    it "returns false and does not increment when already exhausted" do
      invite = create(:group_invite, :exhausted)
      expect(invite.consume!).to be(false)
      expect(invite.reload.uses_count).to eq(1) # unchanged
    end

    it "returns false and does not increment when revoked" do
      invite = create(:group_invite, :revoked)
      expect(invite.consume!).to be(false)
      expect(invite.reload.uses_count).to eq(0)
    end

    it "returns false and does not increment when expired" do
      invite = create(:group_invite, :expired)
      expect(invite.consume!).to be(false)
      expect(invite.reload.uses_count).to eq(0)
    end

    it "is atomic under concurrent consumes: max_uses=1 admits exactly one" do
      invite = create(:group_invite, max_uses: 1)
      results = []
      threads = 5.times.map do
        Thread.new do
          # Use a fresh copy per thread to better simulate separate requests.
          # consume! executes a single UPDATE, so the DB serializes them.
          results << described_class.find(invite.id).consume!
        end
      end
      threads.each(&:join)

      expect(results.count(true)).to eq(1)
      expect(results.count(false)).to eq(4)
      expect(invite.reload.uses_count).to eq(1)
    end
  end

  describe "#revoke!" do
    it "sets revoked_at and makes the invite inactive" do
      invite = create(:group_invite)
      expect { invite.revoke! }
        .to change { invite.revoked_at }.from(nil)
        .and change { invite.active? }.from(true).to(false)
    end
  end
end
