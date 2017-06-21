module Wikipedia
  module VandalismDetection
    # @abstract Exceptions raised by Wikipedia::VandalismDetection inherit from
    #   this Error
    class Error < StandardError; end

    # Exception is raised when trying to classify without a configured
    # classifier
    class ClassifierNotConfiguredError < Error; end

    # Exception is raised when tyring to classifiy with an unknown classifier
    class ClassifierUnknownError < Error; end

    # Exception is raised when trying to use features without having configured
    # some
    class FeaturesNotConfiguredError < Error; end

    # Exception is raised when trying to use edits file without having
    # configured some
    class EditsFileNotConfiguredError < Error; end

    # Exception is raised when trying to use annotations file without having
    # configured some
    class AnnotationsFileNotConfiguredError < Error; end

    # Exception is raised when trying to read revisions directory without
    # having configured some
    class RevisionsDirectoryNotConfiguredError < Error; end

    # Exception is raised when trying to classify without a configured ground
    # thruth test file
    class GroundTruthFileNotConfiguredError < Error; end

    # Exception is raises when there is no arff file available
    class ArffFileNotFoundError < Error; end

    # Exception is raises when there is no ground truth file available
    class GroundTruthFileNotFoundError < Error; end

    # Exceptoion is raised when an already available featture should be added to
    # the arff file
    class FeatureAlreadyUsedError < Error; end

    # Exception is raised when a revisions text file cannot be found and loaded
    class RevisionFileNotFound < Error; end
  end
end
