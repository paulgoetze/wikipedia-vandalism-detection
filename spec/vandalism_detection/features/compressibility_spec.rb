require 'spec_helper'
require 'zlib'

describe Wikipedia::VandalismDetection::Features::Compressibility do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the ratio of compressed text size to uncompressed text size' do
      old_text = 'text'
      new_text = 'text [[If this is a quite long textpart]] of normal words ' \
                 'then it might be less possible to be a vandalism.'

      old_rev = build(:old_revision, text: Text.new(old_text))
      new_rev = build(:new_revision, text: Text.new(new_text))
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      bytesize = 10.0

      Zlib::Deflate.stub(deflate: Text.new)
      Text.any_instance.stub(bytesize: bytesize)
      ratio = bytesize / (bytesize + bytesize)

      expect(subject.calculate(edit)).to eq ratio
    end

    it 'returns 0.5 on emtpy inserted text' do
      old_text = Text.new('deletion text')
      new_text = Text.new(' text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end
  end
end
