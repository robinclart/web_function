# frozen_string_literal: true

module WebFunction
  class Endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def self.invoke(url, bearer_auth: nil, args: {})
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
            details = result[2]

            raise WebFunction::Error.new("#{message} [#{code}]", code: code, details: details)
          end
        when String
          raise WebFunction::Error.new(result)
        else
          raise WebFunction::Error.new("Bad request")
        end
      end

      if response.status != 200
        raise WebFunction::Error.new("Something went wrong, unexpected status code [#{response.status}]")
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
