require "spec_helper"

describe Contractor do
  before(:each) do
    stub_const("TestModule", Module.new)
  end

  describe "examples" do
    it "validates method arguments" do
      module TestModule
        extend Contractor

        contract { integer << [integer, integer] }
        def self.add(x, y)
          x + y
        end
      end

      expect do
        TestModule.add(0.5, 2)
      end.to raise_error(Contractor::CallerViolation, "array element 0 violated integer()")
    end
  end
end
