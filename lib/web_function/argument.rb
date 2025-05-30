# frozen_string_literal: true

module WebFunction
  class Argument
    def initialize(argument)
      @argument = argument
    end

    def name
      @argument["name"]
    end

    def type
      @argument["type"]
    end

    def choices
      @argument["choices"]
    end

    def flags
      @argument["flags"]
    end

    def docs
      @argument["docs"]
    end
  end
end
