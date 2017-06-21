require 'spec_helper'

describe Wikipedia::VandalismDetection::Edit do
  let(:old_revision) { build(:old_revision) }
  let(:new_revision) { build(:new_revision) }
  let(:page_id)      { '1234' }
  let(:page_title)   { 'Page Title' }

  subject { Edit.new(old_revision, new_revision) }

  it 'has an old revision' do
    expect(subject.old_revision).to eq old_revision
  end

  it 'has a new revision' do
    expect(subject.new_revision).to eq new_revision
  end

  it 'has a default page' do
    expect(subject.page).to be_a Page
  end

  it 'can be build with its parent page referenced' do
    page = build(:page, id: page_id, title: page_title)
    edit = Edit.new(old_revision, new_revision, page: page)
    expect(edit.page).to eq page
  end

  describe 'exception handling' do
    it 'raises no error if revisions are not sequent' do
      expect { Edit.new(old_revision, new_revision) }.not_to raise_error
    end

    it 'raises an error if revisions are not sequent' do
      expect { Edit.new(new_revision, old_revision) }
        .to raise_exception ArgumentError
    end
  end

  describe '#serialize' do
    it 'serializes the given parameters into a string' do
      expect(subject.serialize(:id, :text)).to eq "1,text 1\t2,text 2"
    end
  end

  describe '#inserted_words' do
    it 'returns the inserted words as array' do
      old_revision = build(:old_revision, text: '')
      new_revision = build(:new_revision, text: 'inserted words')
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.inserted_words).to eq %w[inserted words]
    end

    it 'returns the uncleaned text inserted words as array' do
      old_revision = build(:old_revision, text: '')
      new_revision = build(:new_revision, text: '[[inserted words]]')
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.inserted_words).to eq %w[[[inserted words]]]
    end
  end

  describe '#inserted_text' do
    it 'returns the inserted text as Text' do
      text = 'inserted words'
      old_revision = build(:old_revision, text: '')
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.inserted_text).to eq Text.new(text)
    end

    it 'returns the uncleaned text inserted text as Text' do
      text = '[[inserted words]]'
      old_revision = build(:old_revision, text: '')
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.inserted_text).to eq Text.new(text)
    end
  end

  describe '#removed_words' do
    it 'returns the removed words as array' do
      old_revision = build(:old_revision, text: 'removed words')
      new_revision = build(:new_revision, text: '')
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.removed_words).to eq %w[removed words]
    end

    it 'returns the uncleaned text rremoved words as array' do
      old_revision = build(:old_revision, text: '[[removed words]]')
      new_revision = build(:new_revision, text: '')
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.removed_words).to eq ['[[removed', 'words]]']
    end
  end

  describe '#removed_text' do
    it 'returns the removed text as Text' do
      text = 'removed words'
      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: '')
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.removed_text).to eq Text.new(text)
    end

    it 'returns the uncleaned text removed text as Text' do
      text = '[[removed words]]'
      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: '')
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(edit.removed_text).to eq Text.new(text)
    end
  end
end
