require 'spec_helper'
require 'wikipedia/vandalism_detection/features/impact_base'

describe Wikipedia::VandalismDetection::Features::ImpactBase do

  before do
    @feature = Wikipedia::VandalismDetection::Features::ImpactBase.new
    @pronouns = Wikipedia::VandalismDetection::WordLists::PRONOUNS
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#impact" do

    it { should respond_to :impact }

    it "returns the impact in percentage of given terms in old realitve to new text" do
      # 3 pronouns
      old_text = "Your old text will be mine or Your's"
      # 4 pronouns
      new_text = "My new text and your old text will be ours and mine"

      text = "I am, i like you."
      expect(@feature.impact(old_text , new_text, @pronouns)).to eq 3.0 / (3.0 + 4.0)
    end

    it "returns 0.0 if old terms word count is zero" do
      new_text = "My new text and your old text will be ours and mine"
      expect(@feature.impact("", new_text, @pronouns)).to eq 0.0
    end

    it "returns 1.0 if new terms word count is zero" do
      old_text = "My new text and your old text will be ours and mine"
      expect(@feature.impact(old_text, "", @pronouns)).to eq 1.0
    end

    it "returns 0.5 if both terms word count is zero" do
      expect(@feature.impact("", "", @pronouns)).to eq 0.5
    end
  end
end
