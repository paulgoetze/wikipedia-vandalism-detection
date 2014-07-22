require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Base do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Base.new
    @edit = build :edit
  end

  describe "#count" do

    before do
      @text = "I,  you: i will help You"
    end

    it { should respond_to(:count).with(2).arguments }

    it "raises an error if option :in is not defined" do
      expect { @feature.count([:i, :you], from: @text) }.to raise_error ArgumentError
    end

    it "raises an error if terms is not an Array or String" do
      expect { @feature.count({term: "You"}, in: @text) }.to raise_error ArgumentError
    end

    it "returns the number of terms in the given text found with the given term array" do
      terms = [:i, :you]
      expect(@feature.count(terms, in: @text)).to eq 4
    end

    it "returns the number of terms in the given text found with the given single term" do
      expect(@feature.count("You", in: @text)).to eq 2
    end
  end


  describe "#calculate" do

    it { should respond_to :calculate }

    it "takes an Wikipedia::Edit as parameter" do
      expect { @feature.calculate(@edit) }.not_to raise_error
    end

    it "raises an ArgumentError if param is no Wikipedia::Edit" do
      expect { @feature.calculate("string") }.to raise_error
    end
  end
end