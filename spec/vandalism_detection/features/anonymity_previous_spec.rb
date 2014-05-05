require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::AnonymityPrevious do

  before do
    @feature = Wikipedia::VandalismDetection::Features::AnonymityPrevious.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "return 1.0 in case of an registered previous editor" do
      @edit = build :edit, old_revision: build(:registered_revision, id: '1')
      @feature.calculate(@edit).should == 1
    end

    it "returns 0.0 in case of an anonymous previous editor" do
      @edit = build :edit, old_revision: build(:anonymous_revision, id: '1')
      @feature.calculate(@edit).should == 0
    end
  end
end