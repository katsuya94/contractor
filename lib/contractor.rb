require "method_decorators"

require "contractor/configuration"
require "contractor/contract"
require "contractor/dsl"
require "contractor/matcher_builder"
require "contractor/matchers"
require "contractor/version"

module Contractor
  def contract(&blk)
    +Contractor::Contract.new(&blk)
  end

  def self.extended(mod)
    mod.extend(MethodDecorators)
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
  class CallerViolation < ContractViolation; end
  class CalleeViolation < ContractViolation; end
end
