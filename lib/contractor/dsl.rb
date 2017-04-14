module Contractor
  class Dsl
    def method_missing(name, *args)
      klass = Contractor.configuration.matchers.get(name)

      raise ConfigurationError, "Unregistered matcher #{name}" if klass.nil?

      MatcherBuilder.new(klass, *args)
    end
  end
end
