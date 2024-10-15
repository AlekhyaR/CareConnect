# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    email { 'user@example.com' }

    trait :patient do
      is_patient { true }
      is_doctor { false }
      is_admin { false }
      email { 'patient@gmail.com' }

      after(:create) do |patient|
        create(:inbox, user: patient)
        create(:outbox, user: patient)
      end
    end

    trait :doctor do
      is_patient { false }
      is_doctor { true }
      is_admin { false }
      email { 'doctor@gmail.com' }

      after(:create) do |doctor|
        create(:inbox, user: doctor)
        create(:outbox, user: doctor)
      end
    end

    trait :admin do
      is_patient { false }
      is_doctor { false }
      is_admin { true }
      email { 'admin@gmail.com' }

      after(:create) do |admin|
        create(:inbox, user: admin)
        create(:outbox, user: admin)
      end
    end
  end

  factory :inbox do
    user
    unread_messages_count { 0 }
  end

  # Factory for Outbox
  factory :outbox do
    user
    sent_messages_count { 0 }
  end

  factory :message do
    body { 'This is a message body.' }
    outbox
    inbox
    read { false }
    association :prescription

    # Optional: If testing replies, we can add a reply_to association
    trait :with_reply do
      association :reply_to, factory: :message
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  first_name :string
#  is_admin   :boolean          default(FALSE), not null
#  is_doctor  :boolean          default(FALSE), not null
#  is_patient :boolean          default(TRUE), not null
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
