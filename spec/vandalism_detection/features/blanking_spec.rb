require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Blanking do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Blanking.new
    @blank_text = "a" * (Wikipedia::VandalismDetection::Features::Blanking::BLANKING_THRESHOLD - 1)
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns 1.0 in case of full blanking (size < BLANKING_THRESHOLD) new revision" do
      old_revision = build(:old_revision, text: "#{@blank_text} additional text")
      new_revision = build(:new_revision, text: @blank_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 1.0
    end

    it "returns 0.0 in case of not full blanking (size >= BLANKING_THRESHOLD) new revision" do
      old_revision = build(:old_revision, text: "#{@blank_text} additional text")
      new_revision = build(:new_revision, text: "#{@blank_text}a")
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end

    it "returns 0.0 if old revision is <= new revision" do
      old_revision = build(:old_revision, text: @blank_text)
      new_revision = build(:new_revision, text: @blank_text.next!)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end