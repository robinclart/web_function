module WebFunction
  # # DocumentedError
  #
  # Represents an error definition as described in a Web Function package.
  #
  # An error definition documents the possible errors that an endpoint might return,
  # including a machine-readable error code and a human-readable description.
  #
  # See the [error definition documentation][0] on the Web Function website for more details,
  # including recognized keys and usage recommendations.
  #
  # [0]: https://webfunction.org/package#error-definition
  #
  class DocumentedError
    def initialize(error)
      @error = error
    end

    # ## Code
    #
    # The code of the error.
    #
    # @return [String]
    #
    def code
      @error["code"]
    end

    # ## Docs
    #
    # The documentation of the error.
    #
    # @return [String]
    #
    def docs
      @error["docs"].to_s
    end
  end
end
