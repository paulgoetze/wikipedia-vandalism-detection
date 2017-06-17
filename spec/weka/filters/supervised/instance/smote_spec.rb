require 'spec_helper'

describe Weka::Filters::Supervised::Instance::SMOTE do
  it { is_expected.to be_a Java::WekaFiltersSupervisedInstance::SMOTE }
end
