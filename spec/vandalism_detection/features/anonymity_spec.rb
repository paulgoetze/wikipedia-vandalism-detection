require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Anonymity do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Anonymity.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "return 1.0 in case of an registered editor" do
      @edit = build :edit, new_revision: build(:registered_revision)
      @feature.calculate(@edit).should == 1
    end

    it "returns 0.0 in case of an anonymous editor" do
      @edit = build :edit, new_revision: build(:anonymous_revision)
      @feature.calculate(@edit).should == 0
    end
  end
end