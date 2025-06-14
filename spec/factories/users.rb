# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    provider { 'email' }
    uid { SecureRandom.uuid }
    active { true }
    is_dummy_password { false }
    line_notice_id { nil }

    trait :line_user do
      provider { 'line' }
      uid { nil } # デフォルトでnilに変更
      email { nil }
      is_dummy_password { true }
    end
  end
end
