FactoryBot.define do
  factory :page, class: Wikipedia::VandalismDetection::Page do
    id { nil }
    title { nil }

    after :build do |obj|
      obj.add_revision FactoryBot.build(:old_revision, contributor: 'User')
      obj.add_revision FactoryBot.build(:new_revision, contributor: 'User')
      obj.add_revision FactoryBot.build(:even_newer_revision, contributor: 'User')
    end
  end
end
