module Contractor
  module Matchers
    class Base
      attr_reader :args
      attr_reader :blk

      def self.name
       @name
      end

      def self.name=(name)
        @name = name
      end

      def initialize(*args, &blk)
        @args = args
        @blk = blk
      end

      def valid?(_object)
        raise NotImplementedError
      end

      def message(_object)
        raise NotImplementedError
      end

      def inspect
        "#{self.class.name}(#{args.map(&:inspect).join(', ')})"
      end
    end

    class Any < Base
      self.name = :any

      def valid?(_object)
        true
      end
    end

    class Integer < Base
      self.name = "integer"

      def valid?(object)
        object.is_a?(Numeric) && object.integer?
      end

      def message(object)
        "#{object.inspect} is not an integer"
      end
    end

    class Array < Base
      self.name = :array

      def valid?(object)
        object.is_a?(Array) && object.zip(matchers).all { |element, matcher| matcher.valid?(element) }
      end

      def message(object)
        if object.is_a?(::Array)
          index = object.zip(matchers).find_index { |element, matcher| !matcher.valid?(element) }
          "array element #{index} violated #{matchers[index].inspect}"
        else
          "#{object.inspect} is not an array"
        end
      end

      private

      def matchers
        args
      end
    end

    class Predicate < Base
      self.name = :pred

      def valid?(object)
        object.respond_to?(method_name) && object.send(method_name)
      end

      def message(object)
        if object.respond_to?(name)
          "#{object.inspect}.#{method_name} was not truthy"
        else
          "#{object.inspect} does not respond to #{method_name.inspect}"
        end
      end

      private

      def method_name
        args[0]
      end
    end

    class Satisfies < Base
      self.name = :satisfies

      def valid?(object)
        blk.call(object)
      end

      def message(object)
        "#{object.inspect} does not satisfy #{blk.inspect}"
      end
    end
  end
end
