require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EmoticonsImpact do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the impact of emoticon words of the new revision text' do
      # 3 emoticons
      old_text = ':) Hi you I got some :-X, you know ;)'

      # 4 emoticons
      new_text = ':) Hi (=you) I added another :-X you know ;)? (='

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / (3.0 + 4.0)
    end

    it 'returns 0.5 if both text revisions have no terms' do
      old_rev = build(:old_revision, text: '')
      new_rev = build(:new_revision, text: '')
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end

    it 'returns 0.0 for an emtpy text in the old revision' do
      old_rev = build(:old_revision, text: '')
      new_rev = build(:new_revision, text: ':)')
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 1.0 for an emtpy text in the new revision' do
      old_rev = build(:old_revision, text: ':)')
      new_rev = build(:new_revision, text: '')
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end
  end
end
