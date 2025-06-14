FactoryBot.define do
  factory :tweet do
    user
    message { Faker::Lorem.sentence }
  end
end
