# Wikipedia Vandalism Detection

Vandalism detection on the Wikipedia history with JRuby.  

The Wikipedia Vandalism Detection Gem uses the Weka Machine-Learning Library via the ruby-band gem.

## What You can do with it

* parsing Wikipedia history pages to get edits and revisions
* creating training ARFF file from
the [PAN 2010 WV Corpus](http://www.uni-weimar.de/en/media/chairs/webis/research/corpora/corpus-pan-wvc-10/) and
the [PAN 2011 WV Corpus](http://www.uni-weimar.de/en/media/chairs/webis/research/corpora/corpus-pan-wvc-11/)
(See also http://pan.webis.de under Wikipedia Vandalsim Detection)

* calculating vandalism features for a Wikipedia page (XML) from the history dump
* creating and evaluate a classifier with the created training ARFF file
* classifing new instances of Wikipedia pages as 'regular' or 'vandalism'

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
      type: Trees::RandomForest
      options: -I 10 -K 0.5
      cross-validation-fold: 5 #default is 10

### Examples

Create training ARFF file from configured corpus:

    Wikipedia::VandalismDetection::TrainingDataset.build!

While creating the training dataset, a corpus file index is created into `build/file_index.yml`.
To run the corpus file index creation manually use:

    Wikipedia::VandalismDetection::TrainingDataset.create_file_index!

Parse a Wikipedia page content:

    # At the moment no namespaces are supported while parsing a page.
    # So, the `<page>...</page>` tags should not be included in a namespaced xml tag!
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

Use a classifier of configured type:

    classifier = Wikipedia::VandalismDetection::Classifier.new

    # Evaluation of the classifier against the configured training corpus
    # classifier.classifier_instance returns the weka classifier instance
    evaluation = classifier.classifier_instance.cross_validate(10)
    puts evaluation.class_details

    # Classification of a Wikipedia Edit or a feature set
    # 'edit' is a Wikipedia::VandalismDetection::Edit, this can be built manually or by
    # parsing a Wikipedia page content and getting its edits
    # The returned consensus is a value between 0.0 and 1.0 were 0.0 means 'regular' and 1.0 means 'vandalism'
    consensus = classifier.classify(edit)

    feature_calculator = Wikipedia::VandalismDetection::FeatureCalculator.new
    features = feature_calculator.calculate_features_for(edit)
    consensus = classifier.classify(features)

## Contributing

1. Fork it ( http://github.com/paulgoetze/wikipedia-vandalism_detection/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
