require 'spec_helper'
require 'zlib'

describe Wikipedia::VandalismDetection::Features::Compressibility do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Compressibility.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the ratio of compressed text size to uncompressed text size" do
      text = "If this is a quite long textpart of normal words then it might be less possible to be a vandalism."

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      ratio = text.bytesize.to_f / (Zlib::Deflate.deflate(text).bytesize.to_f + text.bytesize)
      @feature.calculate(edit).should == ratio
    end

    it "returns 0.5 on emtpy text revisions" do
      text = Wikipedia::VandalismDetection::Text.new ""

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.5
    end
  end
end