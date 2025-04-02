# frozen_string_literal: true

module WebFunction
  class Client
    def initialize(package, bearer_auth: nil)
      @package = package
      @endpoints = package.endpoints.to_h { |e| [e.name.gsub("-", "_").to_sym, e] }
      @bearer_auth = bearer_auth
    end

    attr_reader :package

    def self.from_package_endpoint(url, bearer_auth: nil)
      response = Endpoint.invoke(url, bearer_auth: bearer_auth)
      package = Package.new(response)

      new(package, bearer_auth: bearer_auth)
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

      Endpoint.invoke(url, bearer_auth: @bearer_auth, args: args)
    end
  end
end
