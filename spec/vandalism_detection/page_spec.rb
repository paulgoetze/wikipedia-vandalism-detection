require 'spec_helper'

describe Wikipedia::VandalismDetection::Page do
  describe 'constants' do
    it 'has a START_TAG constant' do
      expect(Page::START_TAG).to eq '<page>'
    end

    it 'has an END_Tag constant' do
      expect(Page::END_TAG).to eq '</page>'
    end
  end

  it 'has a title' do
    expect(subject).to respond_to :title
  end

  it 'has an id' do
    expect(subject).to respond_to :id
  end

  it 'has revisions defaulting to an empty Hash' do
    expect(subject).to respond_to :revisions
    expect(subject.revisions).to be_a Hash
    expect(subject.revisions).to be_empty
  end

  describe '#edits' do
    it { is_expected.to respond_to :edits }

    it 'returns an empty array if no revision is available' do
      expect(subject.revisions).to be_empty
      expect(subject.edits).to be_an Array
      expect(subject.edits).to be_empty
    end

    it 'resets the @revision_added flag to false' do
      subject.add_revision build(:empty_revision, id: '1')
      subject.edits
      expect(subject.instance_variable_get(:@update_edits)).to be false
    end

    it 'computes edits from the page’s revisions' do
      subject.add_revision build(:empty_revision, id: '1')
      subject.add_revision build(:empty_revision, id: '3', parent_id: '2')
      subject.add_revision build(:empty_revision, id: '2', parent_id: '1')

      expect(subject.edits.count).to eq 2
    end

    it 'computes edits of which each holds the parent page as reference' do
      subject.id = '1234'
      subject.title = 'Article'

      subject.add_revision build(:empty_revision, id: '1')
      subject.add_revision build(:empty_revision, id: '3', parent_id: '2')
      subject.add_revision build(:empty_revision, id: '2', parent_id: '1')

      subject.edits.each { |edit| expect(edit.page).to eq subject }
    end
  end

  describe '#add_revision' do
    it { is_expected.to respond_to :add_revision }

    it 'takes a revision and adds it to revisions' do
      revision = build(:empty_revision)

      expect { subject.add_revision(revision) }
        .to change(subject.revisions, :count)
        .by(1)
    end

    it 'sets the @update_edits flag to true after adding a revision' do
      revision = build :empty_revision
      subject.add_revision(revision)
      expect(subject.instance_variable_get(:@update_edits)).to be true
    end

    it 'sets the @update_reverted_edits flag to true after adding a revision' do
      revision = build :empty_revision
      subject.add_revision(revision)
      expect(subject.instance_variable_get(:@update_reverted_edits)).to be true
    end
  end

  describe '#reverted_edits' do
    it { is_expected.to respond_to :reverted_edits }

    it 'returns reverted edits by comparing the sha1 values' do
      # principle:
      # in edit wars the in-between of the first revert triple which has another
      # hash before can be seen as vandalism (here revision with id 2)

      revision_a = build(:empty_revision, id: 1, parent_id: nil, sha1: 'hash0')
      revision_b = build(:empty_revision, id: 2, parent_id: 1, sha1: 'hash1')
      revision_c = build(:empty_revision, id: 3, parent_id: 2, sha1: 'hash2')
      revision_d = build(:empty_revision, id: 4, parent_id: 3, sha1: 'hash1')
      revision_e = build(:empty_revision, id: 5, parent_id: 4, sha1: 'hash2')
      revision_f = build(:empty_revision, id: 6, parent_id: 5, sha1: 'hash3')

      subject.add_revision(revision_c)
      subject.add_revision(revision_f)
      subject.add_revision(revision_a)
      subject.add_revision(revision_e)
      subject.add_revision(revision_d)
      subject.add_revision(revision_b)

      reverted_ids = subject.reverted_edits.map do |edit|
        edit.new_revision.id
      end

      expect(reverted_ids).to eq [revision_c.id]
    end

    it 'returns reverted edit if no previous revision is available' do
      revision_a = build(:empty_revision, id: 1, parent_id: nil, sha1: 'hash1')
      revision_b = build(:empty_revision, id: 2, parent_id: 1, sha1: 'hash2')
      revision_c = build(:empty_revision, id: 3, parent_id: 2, sha1: 'hash1')
      revision_d = build(:empty_revision, id: 4, parent_id: 3, sha1: 'hash2')

      subject.add_revision(revision_c)
      subject.add_revision(revision_a)
      subject.add_revision(revision_d)
      subject.add_revision(revision_b)

      reverted_ids = subject.reverted_edits.map do |edit|
        edit.new_revision.id
      end

      expect(reverted_ids).to eq [revision_b.id]
    end
  end
end
