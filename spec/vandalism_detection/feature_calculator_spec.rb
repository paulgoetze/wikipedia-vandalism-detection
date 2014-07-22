require 'spec_helper'

describe  Wikipedia::VandalismDetection::FeatureCalculator do

  it "raises NoFeaturesConfiguredError when no features are configured" do
    configuration = Wikipedia::VandalismDetection::Configuration.new
    configuration.instance_variable_set :@features, nil

    use_configuration(configuration)

    expect { Wikipedia::VandalismDetection::FeatureCalculator.new }.to raise_error \
        Wikipedia::VandalismDetection::FeaturesNotConfiguredError
  end

  before do
    @calculator = Wikipedia::VandalismDetection::FeatureCalculator.new
  end


  describe "#calculate_features_for" do
    before do
      @edit = build :edit
    end

    it { should respond_to :calculate_features_for }

    it "takes an edit as parameter" do
      expect { @calculator.calculate_features_for(@edit) }.not_to raise_error
    end

    it "raises an error if called with wrong parameter type" do
      revision = build :empty_revision
      expect { @calculator.calculate_features_for(revision) }.to raise_error ArgumentError
    end

    it "returns an array" do
      @calculator.calculate_features_for(@edit).should be_an(Array)
    end

    it "returns the computed feature values" do
      feature_values = @calculator.calculate_features_for(@edit)
      expect( feature_values.select{ |value| value.is_a? Numeric }).to eq feature_values
    end

    it "returns the right number of feature values" do
      expect(@calculator.calculate_features_for(@edit).count).to eq @calculator.used_features.count
    end

    it "uses the cleaned up text if revision contains a #REDIRECT" do
      config = Wikipedia::VandalismDetection.configuration
      redirect_text =  Wikipedia::VandalismDetection::Text.new "#REDIRECT [[Redirect page]]"
      old_revision_redirect = build(:old_revision, text: redirect_text)
      new_revision_redirect = build(:new_revision, text: redirect_text)
      old_revision = build(:old_revision)
      new_revision = build(:new_revision)

      edit_redirect_1 =  Wikipedia::VandalismDetection::Edit.new(old_revision_redirect, new_revision)
      edit_redirect_2 =  Wikipedia::VandalismDetection::Edit.new(old_revision, new_revision_redirect)

      expect(@calculator.calculate_features_for(edit_redirect_1).count).to eq config.features.count
      expect(@calculator.calculate_features_for(edit_redirect_2).count).to eq config.features.count
    end

    it "returns an array holding -1 for not extractable texts in either revision" do
      configuration = Wikipedia::VandalismDetection::Configuration.new
      configuration.instance_variable_set :@features, ['all wordlists impact']

      use_configuration(configuration)
      calculator = Wikipedia::VandalismDetection::FeatureCalculator.new

      unparsable_wiki_text = Wikipedia::VandalismDetection::Text.new "[[Image:img.jpg|\n{|\n|-\n|||| |}"

      old_revision_unparsable = build(:old_revision, text: unparsable_wiki_text)
      new_revision_unparsable = build(:new_revision, text: unparsable_wiki_text)

      old_revision = build(:old_revision)
      new_revision = build(:new_revision)

      edit_1 =  Wikipedia::VandalismDetection::Edit.new(old_revision_unparsable, new_revision)
      edit_2 =  Wikipedia::VandalismDetection::Edit.new(old_revision, new_revision_unparsable)

      expect(calculator.calculate_features_for(edit_1)).to include Wikipedia::VandalismDetection::Features::MISSING_VALUE
      expect(calculator.calculate_features_for(edit_2)).to include Wikipedia::VandalismDetection::Features::MISSING_VALUE
    end
  end

  describe "#claculate_feature_for" do
    before do
      @edit = build :edit
      @feature_name = "anonymity"
      @random_number = rand(1000)
      Wikipedia::VandalismDetection::Features::Anonymity.any_instance.stub(calculate: @random_number)
    end

    it { should respond_to :calculate_feature_for }

    it "takes an edit and feature name as parameter" do
      expect { @calculator.calculate_feature_for(@edit, @feature_name) }.not_to raise_error
    end

    it "raises an error if called with wrong parameter type edit" do
      revision = build :empty_revision
      expect { @calculator.calculate_feature_for(revision, @feature_name) }.to raise_error ArgumentError
    end

    it "raises an error if called with wrong parameter type feature name" do
      revision = build :empty_revision
      expect { @calculator.calculate_feature_for(@edit, revision) }.to raise_error ArgumentError
    end

    it "returns a Numeric" do
      expect(@calculator.calculate_feature_for(@edit, @feature_name)).to be_a Numeric
    end

    it "returns the value calculated by the feature class" do
      expect(@calculator.calculate_feature_for(@edit, @feature_name)).to eq @random_number
    end
  end

  describe "#used_features" do
    it { should respond_to :used_features }

    it "returns an array of the features defined in the config feature.yml" do
      expect(@calculator.used_features.sort).to eq Wikipedia::VandalismDetection.configuration.features.sort
    end
  end
end