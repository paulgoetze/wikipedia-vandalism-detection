# Wikipedia Vandalism Detection

Vandalism detection on the Wikipedia history with JRuby.  

The Wikipedia Vandalism Detection Gem uses the Weka Machine-Learning Library (v3.7.10) via the ruby-band gem.

[![Gem Version](https://badge.fury.io/rb/wikipedia-vandalism_detection.svg)](http://badge.fury.io/rb/wikipedia-vandalism_detection)

## What You can do with it

* parsing Wikipedia history pages to get edits and revisions
* creating training and test ARFF files from
the [WVC-PAN-10](http://www.uni-weimar.de/en/media/chairs/webis/research/corpora/corpus-pan-wvc-10/) and
the [WVC-PAN-11](http://www.uni-weimar.de/en/media/chairs/webis/research/corpora/corpus-pan-wvc-11/)
(See also http://pan.webis.de under category Wikipedia Vandalism Detection)

* calculating vandalism features for a Wikipedia page (XML) from the history dump
* creating and evaluating a classifier with the created training ARFF file
* classifing new instances of Wikipedia edits as 'regular' or 'vandalism'

## Installation

Add this line to your application's Gemfile:

    gem 'wikipedia-vandalism_detection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wikipedia-vandalism_detection

## Usage

    require 'wikipedia/vandalism_detection'

### Configuration

To configure the system put a `wikipedia-vandalism-detection.yml` file in the `config/` or `lib/config/` directory.

You can configure:

A) the training and test corpora directories and essential input and output files

```YAML
corpora:
  base_directory: /home/user/corpora

  training:
    base_directory: training
    annotations_file: annotations.csv
    edits_file: edits.csv
    revisions_directory: revisions

  test:
    base_directory: test
    edits_file: edits.csv
    revisions_directory: revisons

output:
  base_directory: /home/user/output_path
  training:
    arff_file: training.arff
    index_file: training_index.yml
  test:
    arff_file: test.arff
    index_file: test_index.yml
```

Evaluation outputs are saved under the output base directory path.

B) the features used by the feature calculator

```YAML
features:
  - anonymity
  - biased frequency
  - character sequence
  - ...
```

C) the classifier type and its options and the number of cross validation splits for the classifier evaluation

```YAML
classifier:
  type: Trees::RandomForest         # Weka classifier class
  options: -I 10 -K 0.5             # same as for Weka, for further classifier options see Weka-dev documentation
  cross-validation-fold: 5          # default is 10
  training-data-options: balanced   # default is unbalanced
```
      
`training-data-options` is used to resample the training dataset: 

* `unbalanced` is the default value and uses the original dataset 
* `balanced` uses random undersampling of the majority class
* `oversampled` uses SMOTE oversampling (with percentage `-p`) and random undersampling (with minority/majority class balance `-u`) 
  
Examples:

```YAML
# 200% SMOTE oversampling with 300% random undersampling
training-data-options: oversampled -p 200 -u true 300 

# default 100% SMOTE oversampling with 300% random undersampling
training-data-options: oversampled -u true 300 

# 200% SMOTE oversampling with default full (100% minority/majority class balance) 
# random undersampling
training-data-options: oversampled -p 200 

# default 100% SMOTE oversampling without undersampling
training-data-options: oversampled -u false
```
    
Instead of the `true` option you can also use `t`, `y` and `yes` as well as their upper case pendants.

### Examples

**Create training and test ARFF file from configured corpus:**

```ruby
training_dataset = Wikipedia::VandalismDetection::TrainingDataset.build
test_dataset = Wikipedia::VandalismDetection::TestDataset.build
```

While creating the training and test datasets, for each a corpus file index is created into the configured `index_file`
directory.
To run the corpus file index creation manually use:

```ruby
Wikipedia::VandalismDetection::TrainingDataset.create_file_index!
Wikipedia::VandalismDetection::TestDataset.create_file_index!
```

**Parse a Wikipedia page content:**

At the moment no namespaces are supported while parsing a page.
So, the `<page>...</page>` tags should not be included in a namespaced xml tag!

```ruby
xml = File.read(wikipedia_page.xml)
parser = Wikipedia::VandalismDetection::PageParser.new
page = parser.parse(xml)

# Work with revisions and edits from the page
page.revisions.each do |revision|
  puts revison.id
  puts revison.parent_id
end

page.edits.each do |edit|
  puts edit.new_revision.id
  puts edit.old_revision.id
end
```

**Use a classifier of configured type:**

Create the classifier:

```ruby
classifier = Wikipedia::VandalismDetection::Classifier.new
```

Evaluation of the classifier against the configured training corpus:

```ruby
# classifier.classifier_instance returns the weka classifier instance
evaluation = classifier.classifier_instance.cross_validate(10)
puts evaluation.class_details
```

Classify a new edit:

```ruby
# Classification of a Wikipedia Edit or a feature set
# 'edit' is a Wikipedia::VandalismDetection::Edit, this can be built manually or by
# parsing a Wikipedia page content and getting its edits
# The returned confidence is a value between 0.0 and 1.0 were 0.0 means 'regular' and 1.0 means 'vandalism'
confidence = classifier.classify(edit)

feature_calculator = Wikipedia::VandalismDetection::FeatureCalculator.new
features = feature_calculator.calculate_features_for(edit)
confidence = classifier.classify(features)
```

Evaluate test corpus classification:

```ruby
evaluator = classifier.evaluator
# or create a new evaluator
evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

performance_data = evaluator.evaluate_testcorpus_classification #default sample_count = 100
performance_data = evaluator.evaluate_testcorpus_classification(sample_count: 200)

# following attributes can be used for further computations
recall_values = performance_data[:recalls]           # recall values for e.g. x-values of PRC or y-values of ROC
precision_values = performance_data[:precisions]     # precision values for e.g. y-values of PRC
fp_rate_values = performance_data[:fp_rates]         # false positive rate values for e.g. x-values of ROC
area_under_curve_pr = performance_data[:pr_auc]      # computed from the precision and recall values
area_under_curve_ro = performance_data[:roc_auc]     # computed from the recall and fp-rate values
total_recall = performance_data[:total_recall]       # precison and recall values with maximum area (rectangle area)
total_precision = performance_data[:total_precision]
```

Get each features predictive value for analysis:
    
```ruby
evaluator = classifier.evaluator
# or create a new evaluator
evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

analysis_data = evaluator.feature_analysis #default sample_count = 100
analysis_data = evaluator.feature_analysis(sample_count: 1000)
```
    
This returns a hash comprising all feature names as configured as keys and the threshold hashes as values.

```ruby
{
  feature_name_1:
    {
      0.0 => {fp:... , fn:... , tp:... , tn:... },
      ...,
      1.0 => {fp:... , fn:... , tp:... , tn:... }
    },
  ...,
  feature_name_n:
    {
      0.0 => {fp:... , fn:... , tp:... , tn:... },
      ...,
      1.0 => {fp:... , fn:... , tp:... , tn:... }
    },
}
```

**Creating new Features:**

You can define your own new Feature classes and use them by configuration in the config.yml. 

Make sure to define the Feature class inside of the `Wikipedia::VandalismDetection::Features` module 
and to implement the `calculate` method 
(also refer to the `Wikipedia::VandalismDetection::Features::Base` class definition).

```ruby
module Wikipedia
  module VandalismDetection
    module Features
    
      class MyNew < Base
      
        def calculate(edit)
          super # ensures raising an error if 'edit' is not an Edit.
          
          # ...your implementation
        end
        
      end
    end
  end
end
```

While creating new Feature classes you should be aware of the following naming convention: 
The feature's name in the config.yml is the *downcased name with spaces or dashes* of the feature class name

E.g.: 

```YAML
    features: 
      - my new 
      - my-new
```

both search for a Feature class with the name `MyNew`.


## Contributing

1. Fork it ( http://github.com/paulgoetze/wikipedia-vandalism_detection/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
