# spec/factories/groups.rb
FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "グループ#{n}" }
    description { "テスト用グループ" }
    association :created_by, factory: :user
  end
end
