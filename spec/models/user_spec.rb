# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "必須項目" do
      it "メールアドレスがない場合は無効" do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("を入力してください")
      end

      it "名前がない場合は無効" do
        user = build(:user, name: nil)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("を入力してください")
      end
    end

    context "メールアドレスの一意性" do
      it "重複するメールアドレスは無効" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("はすでに存在します")
      end
    end
  end

  describe "役割（role）" do
    context "デフォルト値" do
      it "新規ユーザーはlearnerとして作成される" do
        user = create(:user)
        expect(user).to be_learner
      end
    end

    context "役割の判定メソッド" do
      it "admin?はadminの場合にtrueを返す" do
        user = create(:user, role: :admin)
        expect(user).to be_admin
      end

      it "teacher?はteacherの場合にtrueを返す" do
        user = create(:user, role: :teacher)
        expect(user).to be_teacher
      end
    end
  end

  describe "メール認証（Confirmable）" do
    it "confirmableモジュールが有効である" do
      expect(User.devise_modules).to include(:confirmable)
    end

    it "未確認ユーザーはactive_for_authentication?がfalseを返す" do
      user = build(:user, confirmed_at: nil)
      expect(user.active_for_authentication?).to be false
    end

    it "確認済みユーザーはactive_for_authentication?がtrueを返す" do
      user = build(:user, confirmed_at: Time.current)
      expect(user.active_for_authentication?).to be true
    end

    it "confirmed?メソッドが利用可能である" do
      user = build(:user)
      expect(user).to respond_to(:confirmed?)
    end

    it "confirm メソッドが利用可能である" do
      user = build(:user)
      expect(user).to respond_to(:confirm)
    end
  end

  describe "セッションタイムアウト" do
    it "timeoutableモジュールが有効である" do
      expect(User.devise_modules).to include(:timeoutable)
    end

    it "タイムアウト時間が24時間に設定されている" do
      expect(Devise.timeout_in).to eq(24.hours)
    end

    it "timedout?メソッドが利用可能である" do
      user = build(:user)
      expect(user).to respond_to(:timedout?)
    end
  end

  describe "関連" do
    it { is_expected.to have_many(:group_memberships) }
    it { is_expected.to have_many(:groups).through(:group_memberships) }
    it { is_expected.to have_many(:learning_progresses) }
    it { is_expected.to have_many(:test_submissions) }
  end
end
