# spec/factories/group_memberships.rb
FactoryBot.define do
  factory :group_membership do
    association :user
    association :group
  end
end
