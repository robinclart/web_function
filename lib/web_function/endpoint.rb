module WebFunction
  class Endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def self.invoke(url, bearer_auth: nil, args: {}, options: {})
      headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      }

      if bearer_auth
        headers["Authorization"] = "Bearer #{bearer_auth}"
      end

      response = Excon.post(url,
        headers: headers,
        body: JSON.generate(args),
      )

      result = JSON.parse(response.body)

      if response.status == 400
        case result
        when Array
          if result.length == 3 && result[0].is_a?(String) && result[1].is_a?(String)
            code = result[0]
            message = result[1]

            raise WebFunction::Error, "#{message} [#{code.downcase}]"
          end
        when String
          raise WebFunction::Error, result
        else
          raise WebFunction::Error, "Bad request"
        end
      end

      if response.status != 200
        raise WebFunction::Error, "Something went wrong, got unexpected status code [#{response.status}]"
      end

      result
    end

    def name
      @endpoint["name"]
    end

    def returns
      @endpoint["returns"]
    end

    def flags
      @endpoint["flags"]
    end

    def docs
      @endpoint["docs"]
    end

    def arguments
      @endpoint["arguments"].map { |argument| Argument.new(argument) }
    end
  end
end
