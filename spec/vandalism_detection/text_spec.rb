require 'spec_helper'

describe Wikipedia::VandalismDetection::Text do

  it { should be_a String }
  it { should respond_to :clean }

  describe "#initialze" do
    it "can removes invalid byte sequences" do
      text = Wikipedia::VandalismDetection::Text.new("text \255".force_encoding('UTF-8'))
      expect { text.scan('text') }.not_to raise_error
    end
  end

  describe "#clean" do

    it "raises an WikitextExtractionError if text cannot be parsed" do
      text = Wikipedia::VandalismDetection::Text.new "[[Image:img.jpg|\n{|\n|-\n|||| |}"
      expect { text.clean }.to raise_error Wikipedia::VandalismDetection::WikitextExtractionError
    end

    it "returns the text cleaned from wiki tags" do
      wiki_text = Wikipedia::VandalismDetection::Text.new load_file('sample_revision.txt')
      clean_text = load_file('sample_revision_clean_text.txt')

      expect(wiki_text.clean).to eq clean_text
    end
  end
end