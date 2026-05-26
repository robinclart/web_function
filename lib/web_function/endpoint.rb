# frozen_string_literal: true

module WebFunction
  # # Endpoint
  #
  # Represents an endpoint as described in a Web Function package.
  #
  # An endpoint defines an operation that can be performed via a Web Function API.
  # Endpoints declare their name, documentation, arguments (inputs), attributes (outputs), and
  # the possible errors that may occur when invoking them.
  #
  # Endpoints are described as objects in each package under the `"endpoints"` key.
  # For more information, see:
  # - [Web Function package docs](https://webfunction.org/package)
  # - [Web Function endpoint docs](https://webfunction.org/endpoint)
  #
  # This class provides methods for accessing endpoint metadata (name, docs, arguments, attributes, errors)
  # and supports invocation via HTTP.
  #
  # Typical tasks include:
  # - Querying endpoint name or documentation
  # - Enumerating the arguments or attributes definitions
  # - Invoking the endpoint through HTTP using required inputs
  #
  # See: https://webfunction.org/endpoint for more details on endpoint structure and contract.
  #
  class Endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    class << self
      # ## HTTP client getter
      #
      # The HTTP client used to invoke the endpoint.
      #
      # @return [Proc]
      #
      def http_client
        @http_client ||= proc do |url, headers, body|

          unless body.is_a?(String)
            body = JSON.generate(body)
          end

          response = Excon.post(url, headers: headers, body: body)
          encoding = response.headers["Content-Encoding"] || response.headers["content-encoding"]
          res_body = response.body

          if encoding == "br" && defined?(::Brotli)
            res_body = ::Brotli.inflate(res_body)
          end

          [response.status, res_body]
        end
      end

      # ## HTTP client setter
      #
      # Sets the HTTP client used to invoke the endpoint.
      #
      # To provide a custom HTTP client instead of the default (which uses Excon),
      # set this to any object responding to #call or a Proc/lambda.
      #
      # The contract is:
      #   client.call(url, headers, body)
      #
      # - url:    [String] The full URL to post to (not just the hostname or path).
      # - headers:[Hash<String,String>] HTTP headers, e.g. { "Content-Type" => "application/json" }
      # - body:   [String] The JSON body to post.
      #
      # The client must return a two-element Array: [status, body]:
      # - status: [Integer] HTTP status code (e.g. 200, 400, 500)
      # - body:   [String] Raw response body as a string
      #
      # Example:
      #   WebFunction::Endpoint.http_client = ->(url, headers, args) {
      #     http_response = MyHTTP.post(url, headers: headers, body: JSON.generate(args))
      #     [http_response.status, http_response.body]
      #   }
      #
      # @param http_client [Proc,#call] The new HTTP client to use.
      #
      attr_writer :http_client

      def step(url, bearer_auth: nil, args: {})
        headers = {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "User-Agent" => "webfunction/#{WebFunction::VERSION}",
          "Accept-Encoding" => defined?(::Brotli) ? "gzip, deflate, br" : "gzip, deflate"
        }

        if args.nil?
          args = {}
        end

        if bearer_auth
          headers["Authorization"] = "Bearer #{bearer_auth}"
        end

        {
          url: url,
          headers: headers,
          body: args,
        }
      end

      def invoke(url, bearer_auth: nil, args: {})
        step = self.step(url, bearer_auth: bearer_auth, args: args)
        status, body = http_client.call(url, step[:headers], step[:body])

        unless [200, 400].include?(status)
          raise WebFunction::UnexpectedStatusCodeError.new("Unexpected status code (#{status})",
            code: "UNEXPECTED_STATUS_CODE",
            details: {
              status_code: status,
              raw_body: body,
            },
          )
        end

        begin
          result = JSON.parse(body)
        rescue JSON::ParserError => e
          raise WebFunction::JsonParseError.new(e.message,
            code: "JSON_PARSE_ERROR",
            details: {
              status_code: status,
              raw_body: body,
              original_exception: e,
            },
          )
        end

        if status == 400
          if result.is_a?(String)
            message = result
            code = "BAD_REQUEST"
            details = nil
          elsif result.is_a?(Array) && result.length == 3 && result[0].is_a?(String) && result[1].is_a?(String)
            code = result[0]
            message = result[1]
            details = result[2]
          else
            code = "BAD_REQUEST"
            message = "Bad request"
            details = { body: result }
          end

          raise WebFunction::BadRequestError.new(message, code: code, details: details)
        end

        result
      end
    end

    def name
      @endpoint["name"]
    end

    def returns
      [*@endpoint["returns"]].map { |type| type.to_s }
    end

    def hints
      [*@endpoint["hints"]].map { |hint| hint.to_s }
    end

    def flags
      [*@endpoint["flags"]].map { |flag| flag.to_s }
    end

    def group
      @endpoint["group"]
    end

    def docs
      @endpoint["docs"].to_s
    end

    def arguments
      unless @endpoint["arguments"].is_a?(Array)
        return []
      end

      @endpoint["arguments"].map do |argument|
        unless argument.is_a?(Hash)
          next
        end

        unless argument["name"]
          next
        end

        Argument.new(argument)
      end
    end

    def attributes
      unless @endpoint["attributes"].is_a?(Array)
        return []
      end

      @endpoint["attributes"].map do |attribute|
        unless attribute.is_a?(Hash)
          next
        end

        unless attribute["name"]
          next
        end

        Attribute.new(attribute)
      end
    end

    def errors
      unless @endpoint["errors"].is_a?(Array)
        return []
      end

      @endpoint["errors"].map do |error|
        unless error.is_a?(Hash)
          next
        end

        unless error["code"]
          next
        end

        DocumentedError.new(error)
      end
    end
  end
end
