# frozen_string_literal: true

module WebFunction
  class Client
    def initialize(package, bearer_auth: nil, pipeline: nil)
      @package = package
      @endpoints = package.endpoints.to_h { |e| [e.name.gsub("-", "_").to_sym, e] }
      @bearer_auth = bearer_auth
      @pipeline = pipeline
    end

    attr_reader :package

    def self.from_package_endpoint(url, bearer_auth: nil, pipeline_url: nil, pipeline: nil)
      response = Endpoint.invoke(url, bearer_auth: bearer_auth)
      package = Package.new(response)

      if pipeline.is_a?(String)
        pipeline = WebFunction::Pipeline.new(pipeline)
      end

      new(package, bearer_auth: bearer_auth, pipeline: pipeline)
    end

    def methods
      super + @endpoints.keys
    end

    def respond_to_missing?(method_name, include_private = false)
      @endpoints[method_name] || super
    end

    def method_missing(method_name, *args)
      endpoint = @endpoints[method_name]

      unless endpoint
        super
      end

      url = URI.join(@package.base_url, endpoint.name).to_s
      args = args.first

      if @pipeline
        step = Endpoint.invoke(url, bearer_auth: @bearer_auth, args: args, as_step: true)
        promise = @pipeline.add_step(step)
        return promise
      end

      Endpoint.invoke(url, bearer_auth: @bearer_auth, args: args)
    end
  end
end
