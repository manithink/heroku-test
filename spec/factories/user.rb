FactoryGirl.define do

  factory :user do
    email 'farcare.adm1@gmail.com'
    password 'secret123456789'
    approved true
    # association care_giver_company

    factory :admin do
      after(:create) do |user| 
        user.add_role(:admin)
        user.create_care_giver_company(attributes_for(:care_giver_company))
      end
    end

    factory :pcga do
      after(:create) do |user| 
        user.add_role(:pcga)
        user.create_care_giver_company(attributes_for(:care_giver_company))
      end
    end

    factory :pcg do
      after(:create) do |user| 
        user.add_role(:pcg)
        user.create_care_giver_company(attributes_for(:care_giver_company))
      end
    end

    factory :fcg do
      after(:create) do |user| 
        user.add_role(:fcg)
        user.create_care_giver_company(attributes_for(:care_giver_company))
      end
    end

  end
end
