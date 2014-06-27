require 'spec_helper'
require 'wikipedia/vandalism_detection/instances'

describe Wikipedia::VandalismDetection::Instances do

  it "responds to #empty" do
    expect { Wikipedia::VandalismDetection::Instances.empty }.not_to raise_error
  end

  describe "#empty" do

    before do
      @dataset = Wikipedia::VandalismDetection::Instances.empty
      @attributes = @dataset.enumerate_attributes
      @class_attribute = @dataset.class_attribute
    end

    it "returns a weka dataset" do
      @dataset.class.should == Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      @dataset.n_rows.should == 0
    end

    it "has all configured features and class as attributes" do
      attribute_names = @attributes.map{ |attr| "#{attr.name.gsub('_', ' ')}" }
      features = Wikipedia::VandalismDetection.configuration.features

      attribute_names.should == features
    end

    it "has feature attributes of type 'numeric'" do
      feature_attributes = (@attributes.to_a)[0...-1]
      all_features_numeric = feature_attributes.reduce{ |result, attr| result && attr.numeric? }

      all_features_numeric.should be_true
    end

    it "has a class attribute of type 'nominal'" do
      @class_attribute.nominal?.should be_true
    end

    it "has a class attribute with values 'vandalism' and 'regular'" do
      values = @class_attribute.num_values.times.collect {|index| @class_attribute.value(index) }
      values.should == ['regular','vandalism']
    end
  end

  describe "#empty_for_feature" do
    before do
      @dataset = Wikipedia::VandalismDetection::Instances.empty_for_feature('comment length')
      @attributes = @dataset.enumerate_attributes
      @class_attribute = @dataset.class_attribute
    end

    it "returns a weka dataset" do
      @dataset.class.should == Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      @dataset.n_rows.should == 0
    end

    it "has only given feature and class as attributes" do
      attribute_names = @attributes.map{ |attr| "#{attr.name.gsub('_', ' ')}" }
      features = ['comment length']

      attribute_names.should == features
    end

    it "has feature attributes of type 'numeric'" do
      attribute = (@attributes.to_a)[0]
      attribute.numeric?.should be_true
    end

    it "has a class attribute of type 'nominal'" do
      @class_attribute.nominal?.should be_true
    end

    it "has a class attribute with values 'vandalism' and 'regular'" do
      values = @class_attribute.num_values.times.collect {|index| @class_attribute.value(index) }
      values.should == ['regular','vandalism']
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
      @dataset.class.should == Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      @dataset.n_rows.should == 0
    end

    it "has one given feature as attributes" do
      attribute_name = @feature_attribute.name.gsub('_', ' ')
      attribute_name.should == 'comment length'
    end

    it "has feature attributes of type 'numeric'" do
      @feature_attribute.numeric?.should be_true
    end

    it "has an attribute with name 'oldrevisionid'" do
      @old_revision_id_attribute.name.should == 'oldrevisionid'
    end

    it "has an oldrevisionid attribute of type 'numeric'" do
      @old_revision_id_attribute.numeric?.should be_true
    end

    it "has an attribute with name 'newrevisionid'" do
      @new_revision_id_attribute.name.should == 'newrevisionid'
    end

    it "has a newrevisionid attribute of type 'numeric'" do
      @new_revision_id_attribute.numeric?.should be_true
    end
  end

  describe "#empty_for_test_class" do

    before do
      @dataset = Wikipedia::VandalismDetection::Instances.empty_for_test_class
      @class = @dataset.enumerate_attributes.to_a.first
    end

    it "returns a weka dataset" do
      @dataset.class.should == Java::WekaCore::Instances::Base
    end

    it "returns an empty dataset" do
      @dataset.n_rows.should == 0
    end

    it "has one given feature as attributes" do
      @class.name.should == 'class'
    end

    it "has feature attributes of type 'nominal'" do
      @class.nominal?.should be_true
    end
  end
end