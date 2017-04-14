require "contractor/version"

module Contractor
  class Configuration
    attr_writer :enabled

    attr_accessor :caller_violation_callback
    attr_accessor :callee_violation_callback

    def initialize
      @enabled = true
      self.caller_violation_callback = lambda { |e, continue| raise e }
      self.callee_violation_callback = lambda { |e, continue| raise e }
    end

    def enabled?
      @enabled
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ContractViolation < Error; end

  class CallerViolation < ContractViolation
    attr_reader :arguments
    attr_reader :block

    def initialize(arguments_match_result, block_match_result)
      @arguments = arguments_match_result
      @block = block_match_result
    end
  end

  class CalleeViolation < ContractViolation
    attr_reader :return_value

    def initialize(return_match_result)
      @return_value = return_match_result
    end
  end

  class Contract < MethodDecorators::Decorator
    attr_writer :enabled

    attr_accessor :caller_violation_callback
    attr_accessor :callee_violation_callback

    attr_accessor :arguments_matcher
    attr_accessor :block_matcher
    attr_accessor :return_matcher

    def initialize(options = {}, &blk)
      raise ConfigurationError, "Block must be given when defining a contract" unless block_given?

      @enabled = options[:enabled] || Contractor.configuration.enabled?

      self.caller_violation_callback = options[:caller_violation_callback] || Contractor.configuration.caller_violation_callback
      self.callee_violation_callback = options[:callee_violation_callback] || Contractor.configuration.callee_violation_callback

      dsl = DSL.new
      dsl.instance_eval(&blk)

      self.arguments_matcher = dsl.arguments_matcher
      self.block_matcher = dsl.block_matcher
      self.return_matcher = dsl.return_matcher
    end

    def call(wrapped, _this, *args, &blk)
      return wrapped.call(*args, &blk) unless enabled?

      arguments_match_result = arguments_matcher.match(args)
      block_match_result = block_matcher.match(blk)

      continue = lambda do
        return_value = wrapped.call(*args, &blk)
        return_match_result = return_matcher.match(return_value)

        if return_match_result.valid?
          return_value
        else
          callee_violation_callback.call(CalleeViolation.new(return_match_result), lambda { return_value })
        end
      end

      if arguments_match_result.valid? && block_match_result.valid?
        continue.call
      else
        caller_violation_callback.call(CallerViolation.new(arguments_match_result, block_match_result)
      end
    end

    def enabled?
      @enabled
    end
  end

  class DSL
  end

  module Matchers
    class Matcher
      def match(object)
        raise NotImplementedError
      end
    end

    class Any < Matcher
      def match(object)
        return MatchResult.new(true)
      end
    end
  end

  class MatchResult
    def initialize(valid)
      @valid = valid
    end

    def valid?
      @valid
    end
  end
end
