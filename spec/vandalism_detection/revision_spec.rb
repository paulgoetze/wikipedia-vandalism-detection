require 'spec_helper'

describe Wikipedia::VandalismDetection::Revision do

  describe "constants" do

    it "has a START_TAG constant" do
      Wikipedia::VandalismDetection::Revision::START_TAG.should == '<revision>'
    end

    it "has an END_TAG constant" do
      Wikipedia::VandalismDetection::Revision::END_TAG.should == '</revision>'
    end
  end

  before do
    @revision = Wikipedia::VandalismDetection::Revision.new
    @instance_variables = [:id, :parent_id, :timestamp, :comment, :text, :contributor_id, :contributor_ip]
    @nil_instance_variables = [:id, :parent_id, :timestamp, :contributor_id, :contributor_ip, :contributor_username]
    @read_only_attributes = [:contributor_id, :contributor_ip]
  end

  describe "#anonymous_user?" do
    it { should respond_to :anonymous_contributor? }

    it "returns true in case of an anonymous user" do
      @anonymous_revision = build :anonymous_revision
      @anonymous_revision.anonymous_contributor?.should be_true
    end
  end

  describe "#contributor=" do
    it { should respond_to :contributor= }

    it "sets the @contributor_id if contributor is no IPv4" do
      id = "12345"
      @revision.contributor = id
      @revision.instance_variable_get(:@contributor_id).should == id
      @revision.instance_variable_get(:@contributor_ip).should be_nil
    end

    it "sets the @contributor_ip if contributor is an IPv4" do
      ip = "127.0.0.1"
      @revision.contributor = ip
      @revision.instance_variable_get(:@contributor_ip).should == ip
      @revision.instance_variable_get(:@contributor_id).should be_nil
    end
  end

  it "has the revision attributes" do
    @instance_variables.each do |name|
      @revision.should respond_to name
    end
  end

  it "defaults its attributes to nil" do
    @nil_instance_variables.each do |name|
      @revision.send(name).should be_nil
    end
  end

  it "raises an NoMethod error while accessing read only attributes" do
    @read_only_attributes.each do |name|
      expect { @revision.send("#{name}=", "") }.to raise_error NoMethodError
    end
  end

  it "has an empty default text" do
    @revision.text.should == ''
  end

  it "has a text of type Wikipedia::Text" do
    @revision.text.should be_a Wikipedia::VandalismDetection::Text
  end

  it "has an empty default comment" do
    @revision.comment.should == ''
  end

  it "has a comment of type Wikipedia::Text" do
    @revision.comment.should be_a Wikipedia::VandalismDetection::Text
  end

  it { should respond_to :redirect? }

  it "is marked as redirect if #REDIRECT appears in its text" do
    @revision.text = "#REDIRECT [[Redirect Page Name]]\n"
    @revision.redirect?.should be_true
  end

  it "is not marked as redirect if #REDIRECT does not appear in its text" do
    @revision.text = "''text''"
    @revision.redirect?.should be_false
  end
end