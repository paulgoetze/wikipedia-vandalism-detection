require 'spec_helper'
require 'wikipedia/vandalism_detection/instances'

describe Wikipedia::VandalismDetection::Instances do
  Instances = Wikipedia::VandalismDetection::Instances

  it 'responds to #empty' do
    expect(Instances).to respond_to :empty
  end

  describe '#empty' do
    before do
      use_test_configuration

      @dataset         = Instances.empty
      @attributes      = @dataset.attributes
      @class_attribute = @dataset.class_attribute
    end

    it 'returns a weka dataset' do
      expect(@dataset.class).to eq Java::WekaCore::Instances
    end

    it 'returns an empty dataset' do
      expect(@dataset.size).to eq 0
    end

    it 'has all configured features and class as attributes' do
      names = test_config.features.map { |name| name.tr(' ', '_') }
      expect(@dataset.attribute_names).to eq names
    end

    it 'has feature attributes of type "numeric"' do
      all_features_numeric = @attributes.reduce do |result, attribute|
        result && attribute.numeric?
      end

      expect(all_features_numeric).to be true
    end

    it 'has a nominal class attribute' do
      expect(@class_attribute).to be_nominal
    end

    it 'has a class attribute with values "vandalism" and "regular"' do
      expect(@class_attribute.values).to eq %w[regular vandalism]
    end
  end

  describe '#empty_for_feature' do
    before do
      @dataset         = Instances.empty_for_feature('comment length')
      @attributes      = @dataset.attributes
      @class_attribute = @dataset.class_attribute
    end

    it 'returns a weka dataset' do
      expect(@dataset).to be_a Java::WekaCore::Instances
    end

    it 'returns an empty dataset' do
      expect(@dataset).to be_empty
    end

    it 'has only given feature and class as attributes' do
      expect(@dataset.attribute_names).to eq %w[comment_length]
    end

    it 'has numeric feature attributes' do
      expect(@attributes.first).to be_numeric
    end

    it 'has a nominal class attribute' do
      expect(@class_attribute).to be_nominal
    end

    it 'has a class attribute with values "vandalism" and "regular"' do
      expect(@class_attribute.values).to eq %w[regular vandalism]
    end
  end

  describe '#empty_for_test_feature' do
    before do
      @dataset = Instances.empty_for_test_feature('comment length')

      @feature_attribute         = @dataset.attributes.first
      @old_revision_id_attribute = @dataset.attributes[-2]
      @new_revision_id_attribute = @dataset.attributes.last
    end

    it 'returns a weka dataset' do
      expect(@dataset).to be_a Java::WekaCore::Instances
    end

    it 'returns an empty dataset' do
      expect(@dataset).to be_empty
    end

    it 'has one given feature as attributes' do
      expect(@feature_attribute.name).to eq 'comment_length'
    end

    it 'has numeric feature attributes' do
      expect(@feature_attribute).to be_numeric
    end

    it 'has an attribute with name "oldrevisionid"' do
      expect(@old_revision_id_attribute.name).to  eq 'oldrevisionid'
    end

    it 'has a numeric oldrevisionid attribute' do
      expect(@old_revision_id_attribute).to be_numeric
    end

    it 'has an attribute with name "newrevisionid"' do
      expect(@new_revision_id_attribute.name).to eq 'newrevisionid'
    end

    it 'has a numeric newrevisionid attribute' do
      expect(@new_revision_id_attribute).to be_numeric
    end
  end

  describe '#empty_for_test_class' do
    before do
      @dataset = Instances.empty_for_test_class
      @class   = @dataset.attributes.first
    end

    it 'returns a weka dataset' do
      expect(@dataset).to be_a Java::WekaCore::Instances
    end

    it 'returns an empty dataset' do
      expect(@dataset).to be_empty
    end

    it 'has one given feature as attributes' do
      expect(@class.name).to eq 'class'
    end

    it 'has nominal feature attributes' do
      expect(@class).to be_nominal
    end
  end
end
