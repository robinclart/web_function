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
        "User-Agent": "webfunction/#{WebFunction::VERSION}",
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

            raise WebFunction::Error.new(message, code: code, details: details)
          else
            raise WebFunction::Error.new("Bad request", details: result)
          end
        when String
          raise WebFunction::Error.new(result)
        else
          raise WebFunction::Error.new("Bad request", details: result)
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

    def group
      @endpoint["group"]
    end

    def docs
      @endpoint["docs"]
    end

    def arguments
      unless @endpoint["arguments"].is_a?(Array)
        return []
      end

      @endpoint["arguments"].map { |argument| Argument.new(argument) }
    end

    def attributes
      unless @endpoint["attributes"].is_a?(Array)
        return []
      end

      @endpoint["attributes"].map { |attribute| Attribute.new(attribute) }
    end

    def errors
      unless @endpoint["errors"].is_a?(Array)
        return []
      end

      @endpoint["errors"].map { |error| DocumentedError.new(error) }
    end
  end
end
