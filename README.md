# Wikipedia Vandalism Detection

Vandalism detection on the Wikipedia history with JRuby.  

The Wikipedia Vandalism Detection Gem uses the Weka Machine-Learning Library (v3.7.10) via the ruby-band gem.

## What You can do with it

* parsing Wikipedia history pages to get edits and revisions
* creating training and test ARFF files from
the [PAN 2010 WV Corpus](http://www.uni-weimar.de/en/media/chairs/webis/research/corpora/corpus-pan-wvc-10/) and
the [PAN 2011 WV Corpus](http://www.uni-weimar.de/en/media/chairs/webis/research/corpora/corpus-pan-wvc-11/)
(See also http://pan.webis.de under category Wikipedia Vandalism Detection)

* calculating vandalism features for a Wikipedia page (XML) from the history dump
* creating and evaluate a classifier with the created training ARFF file
* classifing new instances of Wikipedia pages as 'regular' or 'vandalism'

## Installation

To use the Weka machine learning library [ruby-band](https://github.com/paulgoetze/ruby-band/tree/weka-dev)
gem is used. Make shure to use the weka-dev branch of the gem from
[github.com/paulgoetze/ruby-band/tree/weka-dev](https://github.com/paulgoetze/ruby-band/tree/weka-dev)
since the current ruby-band version available by usual gem installation still depends on Weka v1.6.10.

    $ git clone https://github.com/paulgoetze/ruby-band.git -b weka-dev
    $ cd ruby-band
    $ bundle-exec rake install

Add this line to your application's Gemfile:

    gem 'wikipedia-vandalism_detection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wikipedia-vandalism_detection

## Usage

    require 'wikipedia/vandalism_detection'

### Configuration

To configure the system put a `config.yml` file in the `config/` or `lib/config/` directory.

You can configure:

A) the training and test corpora directories and essential input and output files

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

Evaluation outputs are saved under the output base directory path.

B) the features used by the feature calculator

    features:
      - anonymity
      - biased frequency
      - character sequence
      - ...

C) the classifier type and its options and the number of cross validation splits for the classifier evaluation

    classifier:
      type: Trees::RandomForest     # Weka classifier class
      options: -I 10 -K 0.5         # for further classifier options see Weka-dev documentation
      cross-validation-fold: 5      # default is 10
      uniform-training-data: true   # default is false, every other text than 'false' will lead to true

### Examples

**Create training and test ARFF file from configured corpus:**

    Wikipedia::VandalismDetection::TrainingDataset.build!
    Wikipedia::VandalismDetection::TestDataset.build!

While creating the training and test datasets, for each a corpus file index is created into the configured `index_file`
directory.
To run the corpus file index creation manually use:

    Wikipedia::VandalismDetection::TrainingDataset.create_file_index!
    Wikipedia::VandalismDetection::TestDataset.create_file_index!

**Parse a Wikipedia page content:**

At the moment no namespaces are supported while parsing a page.
So, the `<page>...</page>` tags should not be included in a namespaced xml tag!

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

**Use a classifier of configured type:**

    classifier = Wikipedia::VandalismDetection::Classifier.new

Evaluation of the classifier against the configured training corpus:

    # classifier.classifier_instance returns the weka classifier instance
    evaluation = classifier.classifier_instance.cross_validate(10)
    puts evaluation.class_details

Classify a new edit:

    # Classification of a Wikipedia Edit or a feature set
    # 'edit' is a Wikipedia::VandalismDetection::Edit, this can be built manually or by
    # parsing a Wikipedia page content and getting its edits
    # The returned confidence is a value between 0.0 and 1.0 were 0.0 means 'regular' and 1.0 means 'vandalism'
    confidence = classifier.classify(edit)

    feature_calculator = Wikipedia::VandalismDetection::FeatureCalculator.new
    features = feature_calculator.calculate_features_for(edit)
    confidence = classifier.classify(features)

Evaluate test corpus classification:

    evaluator = classifier.evaluator
    #or create a new evaluator
    evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

    performance_data = evaluator.evaluate_testcorpus_classification #default sample_count = 100
    performance_data = evaluator.evaluate_testcorpus_classification(sample_count: sample_count)

    # following attributes can be used for further computations
    recall_values = performance_data[:recalls]           # recall values for e.g. x-values of PRC or y-values of ROC
    precision_values = performance_data[:precisions]     # precision values for e.g. y-values of PRC
    fp_rate_values = performance_data[:fp_rates]         # false positive rate values for e.g. x-values of ROC
    area_under_curve_pr = performance_data[:pr_auc]      # computed from the precision and recall values
    area_under_curve_ro = performance_data[:roc_auc]     # computed from the recall and fp-rate values
    total_recall = performance_data[:total_recall]       # precison and recall values with maximum area (rectangle area)
    total_precision = performance_data[:total_precision]

## Contributing

1. Fork it ( http://github.com/paulgoetze/wikipedia-vandalism_detection/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
