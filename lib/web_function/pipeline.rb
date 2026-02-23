module WebFunction
  class Pipeline
    def initialize(url)
      @url = url
      @steps = []
    end

    def add_step(step)
      n = @steps.count
      @steps << step
      Promise.new(self, "$[#{n}]")
    end

    def execute(returns: "$")
      if returns.to_sym == :last
        returns = "$[-1:]"
      end

      Endpoint.invoke(@url, args: {
        steps: @steps,
        returns: returns,
      })
    end
  end
end
