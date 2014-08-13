require 'spec_helper'
require 'wikipedia/vandalism_detection/instances'

describe Wikipedia::VandalismDetection::Instances do

  it "responds to #empty" do
    expect { Wikipedia::VandalismDetection::Instances.empty }.not_to raise_error
  end

  describe "#empty" do

    before do
      use_test_configuration

      @dataset = Wikipedia::VandalismDetection::Instances.empty
      @attributes = @dataset.enumerate_attributes
      @class_attribute = @dataset.class_attribute
    end

    it "returns a weka dataset" do
      expect(@dataset.class).to eq Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      expect(@dataset.n_rows).to eq 0
    end

    it "has all configured features and class as attributes" do
      attribute_names = @attributes.map{ |attr| "#{attr.name.gsub('_', ' ')}" }
      features = test_config.features

      expect(attribute_names).to eq features
    end

    it "has feature attributes of type 'numeric'" do
      feature_attributes = (@attributes.to_a)[0...-1]
      all_features_numeric = feature_attributes.reduce{ |result, attr| result && attr.numeric? }

      expect(all_features_numeric).to be true
    end

    it "has a class attribute of type 'nominal'" do
      expect(@class_attribute.nominal?).to be true
    end

    it "has a class attribute with values 'vandalism' and 'regular'" do
      values = @class_attribute.num_values.times.collect {|index| @class_attribute.value(index) }
      expect(values).to eq ['regular','vandalism']
    end
  end

  describe "#empty_for_feature" do
    before do
      @dataset = Wikipedia::VandalismDetection::Instances.empty_for_feature('comment length')
      @attributes = @dataset.enumerate_attributes
      @class_attribute = @dataset.class_attribute
    end

    it "returns a weka dataset" do
      expect(@dataset.class).to be Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      expect(@dataset.n_rows).to eq 0
    end

    it "has only given feature and class as attributes" do
      attribute_names = @attributes.map{ |attr| "#{attr.name.gsub('_', ' ')}" }
      features = ['comment length']

      expect(attribute_names).to eq features
    end

    it "has feature attributes of type 'numeric'" do
      attribute = (@attributes.to_a)[0]
      expect(attribute.numeric?).to be true
    end

    it "has a class attribute of type 'nominal'" do
      expect(@class_attribute.nominal?).to be true
    end

    it "has a class attribute with values 'vandalism' and 'regular'" do
      values = @class_attribute.num_values.times.collect {|index| @class_attribute.value(index) }
      expect(values).to eq ['regular','vandalism']
    end
  end

  describe "#empty_for_test_feature" do

    before do
      @dataset = Wikipedia::VandalismDetection::Instances.empty_for_test_feature('comment length')

      @feature_attribute = @dataset.enumerate_attributes.to_a.first
      @old_revision_id_attribute = @dataset.enumerate_attributes.to_a[-2]
      @new_revision_id_attribute = @dataset.enumerate_attributes.to_a.last
    end

    it "returns a weka dataset" do
      expect(@dataset.class).to be Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      expect(@dataset.n_rows).to eq 0
    end

    it "has one given feature as attributes" do
      attribute_name = @feature_attribute.name.gsub('_', ' ')
      expect(attribute_name).to eq 'comment length'
    end

    it "has feature attributes of type 'numeric'" do
      expect(@feature_attribute.numeric?).to be true
    end

    it "has an attribute with name 'oldrevisionid'" do
      expect(@old_revision_id_attribute.name).to  eq 'oldrevisionid'
    end

    it "has an oldrevisionid attribute of type 'numeric'" do
      expect(@old_revision_id_attribute.numeric?).to be true
    end

    it "has an attribute with name 'newrevisionid'" do
      expect(@new_revision_id_attribute.name).to eq 'newrevisionid'
    end

    it "has a newrevisionid attribute of type 'numeric'" do
      expect(@new_revision_id_attribute.numeric?).to be true
    end
  end

  describe "#empty_for_test_class" do

    before do
      @dataset = Wikipedia::VandalismDetection::Instances.empty_for_test_class
      @class = @dataset.enumerate_attributes.to_a.first
    end

    it "returns a weka dataset" do
      expect(@dataset.class).to be Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      expect(@dataset.n_rows).to eq 0
    end

    it "has one given feature as attributes" do
      expect(@class.name).to eq 'class'
    end

    it "has feature attributes of type 'nominal'" do
      expect(@class.nominal?).to be true
    end
  end
end