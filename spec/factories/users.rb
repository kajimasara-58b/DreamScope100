FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { 'Test User' }
    provider { 'email' }
    uid { SecureRandom.uuid }
    is_dummy_password { false }
    active { true }
  end
end