module WebFunction
  class Promise
    def initialize(pipeline, path)
      @pipeline = pipeline
      @path = path
    end

    def to_s
      @path
    end

    def to_json(*args)
      @path.to_json(*args)
    end

    def resolve
      @pipeline.execute(returns: :last)
    end

    def [](key)
      case key
      when String
        mutate("#{@path}[\"#{key}\"]")
      when Integer
        mutate("#{@path}[#{key}]")
      else
        raise ArgumentError
      end
    end

    def method_missing(name, *args)
      if block_given? || args.any?
        super
      end

      mutate("#{@path}.#{name}")
    end

    private

    def mutate(path)
      Promise.new(@pipeline, path)
    end
  end
end
