module WebFunction
  class Promise
    def initialize(pipeline, path)
      @pipeline = pipeline
      @path = Path.new(path)
      @value = nil
    end

    class Path
      def initialize(path)
        @path = path
      end

      def to_s
        @path
      end

      def to_json(*args)
        @path.to_json(*args)
      end

      def [](key)
        case key
        when String, Symbol
          mutate("#{@path}.#{key}")
        when Integer
          mutate("#{@path}[#{key}]")
        else
          raise ArgumentError
        end
      end

      def mutate(path)
        Path.new(path)
      end
    end

    attr_writer :value

    def to_s
      if @value
        @value.to_s
      else
        @path.to_s
      end
    end

    def to_json(*args)
      if @value
        @value.to_json(*args)
      else
        @path.to_json(*args)
      end
    end

    def [](key)
      if @value
        @value[key]
      else
        @path[key]
      end
    end

    def value
      unless @value
        raise UnresolvedPromise
      end

      @value
    end

    def resolve
      if @value
        return @value
      end

      @pipeline.execute

      value
    end
  end
end
