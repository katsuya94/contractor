module Contractor
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

      self.return_matcher, self.arguments_matcher = Dsl.new.instance_eval(&blk)
    end

    def call(wrapped, _this, *args, &blk)
      return wrapped.call(*args, &blk) unless enabled?

      continue = lambda do
        return_value = wrapped.call(*args, &blk)

        if return_matcher.valid?(return_value)
          return_value
        else
          callee_violation_callback.call(CalleeViolation.new(return_matcher.message(return_value)), lambda { return_value })
        end
      end

      if arguments_matcher.valid?(args)
        continue.call
      else
        caller_violation_callback.call(CallerViolation.new(arguments_matcher.message(args)), continue)
      end
    end

    def enabled?
      @enabled
    end
  end
end
