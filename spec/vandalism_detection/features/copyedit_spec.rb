require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Copyedit do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Copyedit.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::ContainsBase }

  describe "#calculate" do

    it "returns 1 if the edit comment includes 'copyedit'" do
      comment = Wikipedia::VandalismDetection::Text.new "copyediting content"
      edit = build :edit, new_revision: build(:new_revision, comment: comment)

      expect(@feature.calculate(edit)).to eq 1
    end

    it "returns 1 if the edit comment includes 'copy edit'" do
      comment = Wikipedia::VandalismDetection::Text.new "copy editing content"
      edit = build :edit, new_revision: build(:new_revision, comment: comment)

      expect(@feature.calculate(edit)).to eq 1
    end

    it "returns 0 on emtpy comment" do
      edit = build :edit, new_revision: build(:new_revision, comment: "")

      expect(@feature.calculate(edit)).to eq 0
    end
  end
end