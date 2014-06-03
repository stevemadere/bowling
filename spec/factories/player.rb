
FactoryGirl.define do
  factory :player do
    name {Faker::Internet.user_name}
  end
end


