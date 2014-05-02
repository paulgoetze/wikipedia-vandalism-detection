require 'spec_helper'
require 'zlib'

describe Wikipedia::VandalismDetection::Features::Compressibility do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Compressibility.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the ratio of compressed text size to uncompressed text size" do
      old_text = 'text'
      new_text = 'text [[If this is a quite long textpart]] of normal words then it might be less possible to be a vandalism.'

      old_revision = build(:old_revision, text: Wikipedia::VandalismDetection::Text.new(old_text))
      new_revision = build(:new_revision, text: Wikipedia::VandalismDetection::Text.new(new_text))
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      bytesize = 10.0

      Zlib::Deflate.stub(deflate: Wikipedia::VandalismDetection::Text.new)
      Wikipedia::VandalismDetection::Text.any_instance.stub(bytesize: bytesize)
      ratio = bytesize / (bytesize + bytesize)

      @feature.calculate(edit).should == ratio
    end

    it "returns 0.5 on emtpy inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new("deletion text")
      new_text = Wikipedia::VandalismDetection::Text.new(" text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.5
    end
  end
end