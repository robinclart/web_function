# frozen_string_literal: true

module WebFunction
  # # Attribute
  #
  # An Attribute defines an output field that may be produced and returned by a
  # Web Function endpoint.
  #
  # See the [attributes section][0] on the Web Function website for more
  # details about attribute definitions, recognized keys, and usage.
  #
  # [0]: https://webfunction.org/package#attributes
  #
  class Attribute
    def initialize(attribute)
      @attribute = attribute
    end

    # ## Name
    #
    # The name of the attribute as it will appear in the endpoint's output
    # object.
    #
    # @return [String]
    #
    def name
      @attribute["name"]
    end

    # ## Type
    #
    # The type of value returned for this attribute. Must be one of:
    #   - object
    #   - array
    #   - string
    #   - number
    #   - boolean
    #
    # This is a required string.
    #
    # @return [String]
    #
    def type
      @attribute["type"]
    end

    # ## Hint
    #
    # A string hinting about the semantics of this attribute. See the
    # [hints section][1] for possible values and documentation tooling guidance.
    #
    # [1]: https://webfunction.org/package#hints
    #
    # @return [String, nil]
    #
    def hint
      @attribute["hint"]
    end

    # ## Values
    #
    # An array specifying the exact, case-sensitive values that may be returned 
    # for this attribute. Each value in the values array must conform to the 
    # data type specified in the "type" key.
    #
    # This is useful for attributes that can only take a select set of values
    # (enums or constants).
    #
    # @return [Array]
    #
    def values
      [*@attribute["values"]]
    end

    # ## Flags
    #
    # An array of attribute flags. Flags describe special characteristics or 
    # behaviors of attributes. See the [available flags section][2] for 
    # complete list and documentation.
    #
    # [2]: https://webfunction.org/package#available-flags
    #
    # @return [Array<String>]
    #
    def flags
      [*@attribute["flags"]].map(&:to_s)
    end

    # ## Docs
    #
    # A markdown string describing this attribute and its purpose in the output 
    # object. Used by documentation tools, and highly recommended.
    #
    # @return [String]
    #
    def docs
      @attribute["docs"].to_s
    end
  end
end
