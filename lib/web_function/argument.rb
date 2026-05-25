# frozen_string_literal: true

module WebFunction
  # # Argument
  #
  # Arguments used by Web Function endpoints to define its input parameters.
  #
  # See the [arguments section][0] on the Web Function website for more details.
  #
  # [0]: https://webfunction.org/package#arguments
  #
  class Argument
    def initialize(argument)
      @argument = argument
    end

    # ## Name
    #
    # The name of the argument.
    #
    # @return [String]
    #
    def name
      @argument["name"]
    end

    # ## Type
    #
    # The type of the argument. It must be one of:
    #   - object
    #   - array
    #   - string
    #   - number
    #   - boolean
    #
    # @return [String]
    #
    def type
      @argument["type"]
    end

    # ## Hint
    #
    # The hint of the argument
    #
    # See the [hints section][1] on the Web Function website for the full list 
    # of possible hints.
    #
    # @return [String]
    #
    # [1]: https://webfunction.org/package#hints
    #
    def hint
      @argument["hint"]
    end

    # ## Group
    #
    # A name used to categorize or group similar arguments together. This 
    # should be used by documentation tools to organize related arguments.
    #
    # @return [String]
    #
    def group
      @argument["group"]
    end

    # ## Choices
    #
    # An array specifying the exact, case-sensitive values that are permitted
    # for this argument. Each value in the choices array must conform to the
    # data type specified in the argument's type key.
    #
    # Note that if the argument type is array, choices may contain strings or
    # numbers representing the allowed values that can be included in the array.
    #
    # @return [Array]
    #
    def choices
      [*@argument["choices"]]
    end

    # ## Flags
    #
    # List of argument flags. See the [available flags section][2] on the Web
    # Function website for a complete list of flags available at the
    # argument level.
    #
    # @return [Array<String>]
    #
    # [2]: https://webfunction.org/package#available-flags
    #
    def flags
      [*@argument["flags"]].map { |flag| flag.to_s }
    end

    # ## Docs
    #
    # Description of the argument. It must be formatted as markdown.
    #
    # @return [String]
    #
    def docs
      @argument["docs"].to_s
    end
  end
end
