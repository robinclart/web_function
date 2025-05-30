module WebFunction
  class DocumentedError
    def initialize(error)
      @error = error
    end

    def code
      @error["code"]
    end

    def docs
      @error["docs"]
    end
  end
end