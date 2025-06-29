# frozen_string_literal: true

module WebFunction
  class Attribute
    def initialize(attribute)
      @attribute = attribute
    end

    def name
      @attribute["name"]
    end

    def type
      @attribute["type"]
    end

    def values
      @attribute["values"]
    end

    def flags
      @attribute["flags"]
    end

    def docs
      @attribute["docs"]
    end
  end
end
