# frozen_string_literal: true

module WebFunction
  # A {Client} is a wrapper around a Web Function {Package} that provides a convenient interface for invoking endpoints.
  #
  # @example
  #   client = WebFunction::Client.from_package_endpoint("https://api.webfunction.com/package")
  #   client.list_items(a: "b") # => { "c" => "d" }
  #
  class Client < BasicObject
    def initialize(base_url:, endpoints: [], package: nil, bearer_auth: nil, version: nil, pipeline: nil)
      @package = package
      @base_url = base_url
      @endpoints = endpoints.to_h { |e| [e.gsub("-", "_").to_sym, e] }
      @bearer_auth = bearer_auth
      @version = version
      @pipeline = pipeline
    end

    class << self
      # Creates a new {Client} from an url.
      #
      # @param url [String] The URL of the package endpoint
      # @param bearer_auth [String] The bearer authentication token
      # @param version [String] The API version to use
      # @param pipelined [Boolean] Whether to have the client use call pipelining
      #
      # @return [Client]
      #
      def from_package_endpoint(url, bearer_auth: nil, version: nil, pipelined: false)
        response = ::WebFunction::Request.execute(url, bearer_auth: bearer_auth, version: version)
        package = ::WebFunction::Package.from_hash(response)

        from_package(package, bearer_auth: bearer_auth, version: version, pipelined: pipelined)
      end

      # Creates a new {Client} from a {Package}.
      #
      # @param package [Package] A package
      # @param bearer_auth [String] The bearer authentication token
      # @param version [String] The API version to use
      # @param pipelined [Boolean] Whether to have the client use call pipelining
      #
      # @return [Client]
      #
      def from_package(package, bearer_auth: nil, version: nil, pipelined: nil)
        pipeline = nil

        if pipelined
          pipeline = package.pipeline
        end

        client = new(
          package: package,
          base_url: package.base_url,
          endpoints: package.endpoints.map(&:name),
          bearer_auth: bearer_auth,
          version: version,
          pipeline: pipeline,
        )

        package.endpoints.each do |endpoint|
          endpoint.client = client
        end

        client
      end
    end

    # Call an endpoint by name with the given arguments.
    #
    # @param endpoint_name [String] The name of the endpoint to call
    # @param args [Hash] The arguments to send to the endpoint
    #
    # @return [Object] The decoded response returned by the endpoint
    #
    def call(endpoint_name, args = {})
      url = ::URI.join(@base_url, endpoint_name).to_s
      request = ::WebFunction::Request.new(url,
        bearer_auth: @bearer_auth,
        version: @version,
        args: args,
      )

      if @pipeline
        @pipeline.add_step(request.as_pipeline_step)
      else
        request.execute
      end
    end

    # The package that this client is wrapping.
    #
    # @return [Package]
    #
    attr_reader :package

    def methods # :nodoc:
      @endpoints.keys
    end

    def respond_to_missing?(method_name, include_private = false) # :nodoc:
      @endpoints[method_name]
    end

    def method_missing(method_name, *args) # :nodoc:
      endpoint_name = @endpoints[method_name]

      unless endpoint_name
        super
      end

      call(endpoint_name, args.first)
    end
  end
end
