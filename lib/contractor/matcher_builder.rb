module Contractor
  class MatcherBuilder
    def initialize(klass, *args)
      @klass = klass
      @args = args
    end

    def build
      @klass.new(*@args.map { |arg| transform(arg) })
    end

    def <<(argument_matcher_builders)
      raise ConfigurationError, "The right side of the contract must be an array" unless argument_matcher_builders.is_a?(Array)
      [build, Contractor::Matchers::Array.new(*argument_matcher_builders.map { |arg| transform(arg) })]
    end

    private

    def transform(object)
      object.is_a?(MatcherBuilder) ? object.build : object
    end
  end
end
