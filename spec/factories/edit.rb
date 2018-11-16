FactoryBot.define do
  factory :edit, class: Wikipedia::VandalismDetection::Edit do
    old_revision { FactoryBot.build(:old_revision) }
    new_revision { FactoryBot.build(:new_revision) }
    page_id { nil }
    page_title { nil }

    initialize_with { new(old_revision, new_revision, page_id: page_id, page_title: page_title) }
  end

  factory :anonymous_edit, class: Wikipedia::VandalismDetection::Edit do
    old_revision { FactoryBot.build(:old_revision) }
    new_revision { FactoryBot.build(:anonymous_revision) }
    page_id { nil }
    page_title { nil }

    initialize_with { new(old_revision, new_revision, page_id: page_id, page_title: page_title) }
  end
end
