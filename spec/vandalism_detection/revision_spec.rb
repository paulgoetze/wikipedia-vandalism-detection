require 'spec_helper'

describe Wikipedia::VandalismDetection::Revision do

  describe "constants" do

    it "has a START_TAG constant" do
      expect(Wikipedia::VandalismDetection::Revision::START_TAG).to eq '<revision>'
    end

    it "has an END_TAG constant" do
      expect(Wikipedia::VandalismDetection::Revision::END_TAG).to eq '</revision>'
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
      expect(@anonymous_revision.anonymous_contributor?).to be true
    end
  end

  describe "#contributor=" do
    it { should respond_to :contributor= }

    it "sets the @contributor_id if contributor is no IPv4" do
      id = "12345"
      @revision.contributor = id

      expect(@revision.instance_variable_get(:@contributor_id)).to eq id
      expect(@revision.instance_variable_get(:@contributor_ip)).to be_nil
    end

    it "sets the @contributor_ip if contributor is an IPv4" do
      ip = "127.0.0.1"
      @revision.contributor = ip

      expect(@revision.instance_variable_get(:@contributor_ip)).to eq ip
      expect(@revision.instance_variable_get(:@contributor_id)).to be_nil
    end
  end

  describe "#contributor" do
    it { should respond_to :contributor }

    it "returns the contributor_id if set" do
      id = "12345"
      @revision.contributor = id

      expect(@revision.contributor).to eq @revision.instance_variable_get(:@contributor_id)
    end

    it "returns the contributor_ip if set" do
      ip = "127.0.0.1"
      @revision.contributor = ip

      expect(@revision.contributor).to eq @revision.instance_variable_get(:@contributor_ip)
    end
  end

  it "has the revision attributes" do
    @instance_variables.each do |name|
      expect(@revision).to respond_to name
    end
  end

  it "defaults its attributes to nil" do
    @nil_instance_variables.each do |name|
      expect(@revision.send(name)).to be_nil
    end
  end

  it "raises an NoMethod error while accessing read only attributes" do
    @read_only_attributes.each do |name|
      expect { @revision.send("#{name}=", "") }.to raise_error NoMethodError
    end
  end

  it "has an empty default text" do
    expect(@revision.text).to be_empty
  end

  it "has a text of type Wikipedia::Text" do
    expect(@revision.text).to be_a Wikipedia::VandalismDetection::Text
  end

  it "has an empty default comment" do
    expect(@revision.comment).to be_empty
  end

  it "has a comment of type Wikipedia::Text" do
    expect(@revision.comment).to be_a Wikipedia::VandalismDetection::Text
  end

  it { should respond_to :redirect? }

  it "is marked as redirect if #REDIRECT appears in its text" do
    @revision.text = "#REDIRECT [[Redirect Page Name]]\n"
    expect(@revision.redirect?).to be true
  end

  it "is not marked as redirect if #REDIRECT does not appear in its text" do
    @revision.text = "''text''"
    expect(@revision.redirect?).to be false
  end
end