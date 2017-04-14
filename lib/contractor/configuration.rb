module Contractor
  class Configuration
    class MatcherRegistrations
      def initialize
        @matchers = {}
      end

      def register(klass)
        raise ConfigurationError, "#{klass}.name must not be nil" if klass.nil?
        @matchers[klass.name.to_sym] = klass
      end

      def get(name)
        @matchers[name.to_sym]
      end

      def names
        @matchers.keys
      end
    end

    attr_writer :enabled

    attr_accessor :caller_violation_callback
    attr_accessor :callee_violation_callback

    attr_accessor :matchers

    def initialize
      @enabled = true

      self.caller_violation_callback = lambda { |e, continue| raise e }
      self.callee_violation_callback = lambda { |e, continue| raise e }

      self.matchers = MatcherRegistrations.new

      matchers.register(Matchers::Any)
      matchers.register(Matchers::Integer)
      matchers.register(Matchers::Predicate)
    end

    def enabled?
      @enabled
    end
  end
end
