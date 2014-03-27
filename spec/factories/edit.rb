FactoryGirl.define do

  factory :edit, class: Wikipedia::VandalismDetection::Edit do
    old_revision { FactoryGirl.build(:old_revision) }
    new_revision { FactoryGirl.build(:new_revision) }

    initialize_with { new(old_revision, new_revision) }
  end

  factory :anonymous_edit, class: Wikipedia::VandalismDetection::Edit do
    old_revision { FactoryGirl.build(:old_revision) }
    new_revision { FactoryGirl.build(:anonymous_revision) }

    initialize_with { new(old_revision, new_revision) }
  end
end