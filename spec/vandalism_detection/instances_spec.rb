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
      features = Wikipedia::VandalismDetection.configuration["features"]

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
      values.should == ['vandalism', 'regular']
    end
  end
end