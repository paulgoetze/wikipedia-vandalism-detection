require 'spec_helper'

describe Wikipedia::VandalismDetection::Algorithms::KullbackLeiblerDivergence do

  it { should respond_to :of }

  describe "#of" do
    before do
      @divergence = Wikipedia::VandalismDetection::Algorithms::KullbackLeiblerDivergence.new
    end

    it "returns invalid value representation if no characters in given both texts" do
      @divergence.of("&", "?").should == Wikipedia::VandalismDetection::Features::MISSING_VALUE
    end

    it "returns a value of zero if texts are the same" do
      @divergence.of("Text sample", "Text sample").should == 0.0
    end

    it "returns a value bigger than zero for different texts" do
      @divergence.of("Text 1", "Text 2").should be > 0.0
    end

    it "returns a higher value for a more different text" do
      divergence_lower = @divergence.of("text a", "text b")
      divergence_higher = @divergence.of("text a", "bla bla bla")

      divergence_lower.should be < divergence_higher
    end

    it "can handle invalid byte sequences" do
      invalid_byte_sequence = "text \255".force_encoding('UTF-8')
      expect { @divergence.of(invalid_byte_sequence, invalid_byte_sequence) }.not_to raise_error
    end
  end
end