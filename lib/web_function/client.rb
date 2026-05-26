# frozen_string_literal: true

module WebFunction
  # # Client
  #
  # A Client is a wrapper around a Web Function package that provides a 
  # convenient interface for invoking endpoints.
  #
  # @example
  #   client = WebFunction::Client.from_package_endpoint("https://api.webfunction.com/package")
  #   client.list_items(a: "b") # => { "c" => "d" }
  #
  class Client
    def initialize(package, bearer_auth: nil, pipeline: nil)
      @package = package
      @endpoints = package.endpoints.to_h { |e| [e.name.gsub("-", "_").to_sym, e] }
      @bearer_auth = bearer_auth
      @pipeline = pipeline
    end

    attr_reader :package

    # ## Instantiates a new Client from a package endpoint
    #
    # Creates a new Client from a package endpoint.
    #
    # @param url [String] The URL of the package endpoint
    # @param bearer_auth [String] The bearer authentication token
    # @param pipeline_url [String] The URL of the pipeline endpoint
    # @param pipeline [Pipeline] The pipeline to use
    #
    # @return [Client] A new Client instance
    #
    def self.from_package_endpoint(url, bearer_auth: nil, pipeline_url: nil, pipeline: nil)
      response = ::WebFunction::Endpoint.invoke(url, bearer_auth: bearer_auth)
      package = ::WebFunction::Package.new(response)

      if pipeline_url.is_a?(::String)
        pipeline = ::WebFunction::Pipeline.new(pipeline_url)
      elsif pipeline.is_a?(::String)
        pipeline = ::WebFunction::Pipeline.new(pipeline)
      end

      new(package, bearer_auth: bearer_auth, pipeline: pipeline)
    end

    def methods #:nodoc:
      super + @endpoints.keys
    end

    def respond_to_missing?(method_name, include_private = false) #:nodoc:
      @endpoints[method_name] || super
    end

    def method_missing(method_name, *args) #:nodoc:
      endpoint = @endpoints[method_name]

      unless endpoint
        super
      end

      base_url = @package.base_url
      base_url += "/" unless base_url.end_with?("/")
      url = ::URI.join(base_url, endpoint.name).to_s
      args = args.first

      if @pipeline
        step = ::WebFunction::Endpoint.step(url, bearer_auth: @bearer_auth, args: args)
        promise = @pipeline.add_step(step)
        return promise
      end

      ::WebFunction::Endpoint.invoke(url, bearer_auth: @bearer_auth, args: args)
    end
  end
end
