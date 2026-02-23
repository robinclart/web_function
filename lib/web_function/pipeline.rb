module WebFunction
  class Pipeline
    def initialize(url)
      @url = url
      @steps = []
      @promises = []
    end

    def add_step(step)
      n = @promises.count
      promise = Promise.new(self, "$[#{n}]")

      @steps << step
      @promises << promise

      promise
    end

    def execute(returns: :all)
      case returns
      when :all
        responses = Endpoint.invoke(@url, args: {
          steps: @steps,
          returns: "$",
        })

        responses.each_with_index do |response, index|
          @promises[index].value = response
        end

        reset!

        responses
      when :last
        response = Endpoint.invoke(@url, args: {
          steps: @steps,
          returns: "$[-1:]",
        })

        @promises.last.value = response

        reset!

        response
      else
        response = Endpoint.invoke(@url, args: {
          steps: @steps,
          returns: returns,
        })

        reset!

        response
      end
    end

    def reset!
      @steps = []
      @promises = []
    end
  end
end
