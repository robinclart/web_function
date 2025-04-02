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

    def flags
      @argument["flags"]
    end

    def docs
      @argument["docs"]
    end

    def to_s
      ["  - #{name} (#{type}):", docs].join(" ")
    end
  end
end
