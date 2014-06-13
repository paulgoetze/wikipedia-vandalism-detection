require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentSexFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CommentSexFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of sex words in comment relative to all words count" do
      # total 11 words, 7 sex words
      comment = Wikipedia::VandalismDetection::Text.new 'Penis was penis if penis was penis and penis are penis'

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 6.0 / 11.0
    end

    it "returns 0.0 on emtpy clean text comment" do
      comment = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end