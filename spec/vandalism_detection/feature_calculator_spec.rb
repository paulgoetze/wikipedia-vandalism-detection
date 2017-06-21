require 'spec_helper'

describe Wikipedia::VandalismDetection::FeatureCalculator do
  let(:edit) { build(:edit) }

  it 'raises NoFeaturesConfiguredError when no features are configured' do
    config = Wikipedia::VandalismDetection::Configuration.send(:new)
    config.instance_variable_set(:@features, nil)

    use_configuration(config)

    expect { Wikipedia::VandalismDetection::FeatureCalculator.new }
      .to raise_error Wikipedia::VandalismDetection::FeaturesNotConfiguredError
  end

  before do
    use_test_configuration
    @calculator = Wikipedia::VandalismDetection::FeatureCalculator.new
  end

  describe '#calculate_features_for' do
    it { is_expected.to respond_to :calculate_features_for }

    it 'takes an edit as parameter' do
      expect { @calculator.calculate_features_for(edit) }.not_to raise_error
    end

    it 'raises an error if called with wrong parameter type' do
      revision = build(:empty_revision)
      expect { @calculator.calculate_features_for(revision) }
        .to raise_error ArgumentError
    end

    it 'returns an array' do
      expect(@calculator.calculate_features_for(edit)).to be_an Array
    end

    it 'returns the computed numeric feature values' do
      feature_values = @calculator.calculate_features_for(edit)
      expect(feature_values.all? { |value| value.is_a?(Numeric) }).to be true
    end

    it 'returns the right number of feature values' do
      count = @calculator.used_features.count
      expect(@calculator.calculate_features_for(edit).count).to eq count
    end

    it 'uses the cleaned up text if revision contains a #REDIRECT' do
      redirect_text = Text.new('#REDIRECT [[Redirect page]]')
      old_revision_redirect = build(:old_revision, text: redirect_text)
      new_revision_redirect = build(:new_revision, text: redirect_text)
      old_revision = build(:old_revision)
      new_revision = build(:new_revision)

      edit_a = Wikipedia::VandalismDetection::Edit.new(old_revision_redirect, new_revision)
      edit_b = Wikipedia::VandalismDetection::Edit.new(old_revision, new_revision_redirect)

      config = Wikipedia::VandalismDetection.config
      count = config.features.count

      expect(@calculator.calculate_features_for(edit_a).count).to eq count
      expect(@calculator.calculate_features_for(edit_b).count).to eq count
    end

    it 'includes -1 for not extractable texts in either revision' do
      config = Wikipedia::VandalismDetection::Configuration.instance
      config.instance_variable_set(:@features, ['all wordlists impact'])

      use_configuration(config)

      unparsable_wiki_text = Text.new("[[Image:img.jpg|\n{|\n|-\n|||| |}")

      old_revision_unparsable = build(:old_revision, text: unparsable_wiki_text)
      new_revision_unparsable = build(:new_revision, text: unparsable_wiki_text)

      old_revision = build(:old_revision)
      new_revision = build(:new_revision)

      edit_a = Wikipedia::VandalismDetection::Edit.new(old_revision_unparsable, new_revision)
      edit_b = Wikipedia::VandalismDetection::Edit.new(old_revision, new_revision_unparsable)

      expect(subject.calculate_features_for(edit_a)).to include Features::MISSING_VALUE
      expect(subject.calculate_features_for(edit_b)).to include Features::MISSING_VALUE
    end
  end

  describe '#claculate_feature_for' do
    let(:feature_name) { 'anonymity' }
    let(:random_number) { rand(1000) }
    let(:empty_revision) { build(:empty_revision) }

    before { Features::Anonymity.any_instance.stub(calculate: random_number) }

    it { is_expected.to respond_to :calculate_feature_for }

    it 'takes an edit and feature name as parameter' do
      expect { @calculator.calculate_feature_for(edit, feature_name) }
        .not_to raise_error
    end

    it 'raises an error if called with wrong parameter type edit' do
      expect { @calculator.calculate_feature_for(empty_revision, feature_name) }
        .to raise_error ArgumentError
    end

    it 'raises an error if called with wrong parameter type feature name' do
      expect { @calculator.calculate_feature_for(edit, empty_revision) }
        .to raise_error ArgumentError
    end

    it 'returns a Numeric' do
      expect(@calculator.calculate_feature_for(edit, feature_name))
        .to be_a Numeric
    end

    it 'returns the value calculated by the feature class' do
      expect(@calculator.calculate_feature_for(edit, feature_name))
        .to eq random_number
    end
  end

  describe '#used_features' do
    it { is_expected.to respond_to :used_features }

    it 'returns an array of the features defined in the config feature.yml' do
      features = Wikipedia::VandalismDetection.config.features
      expect(@calculator.used_features).to match_array features
    end
  end
end
