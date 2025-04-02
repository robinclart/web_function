module WebFunction
  class Client
    def initialize(package, bearer_auth: nil)
      @package = package
      @endpoints = Hash[package.endpoints.map { |e| [e.name.gsub("-", "_").to_sym, e] }]
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

    def method_missing(name, *args)
      endpoint = @endpoints[name]

      unless endpoint
        super
      end

      url = URI.join(@package.base_url, endpoint.name).to_s

      Endpoint.invoke(url, bearer_auth: @bearer_auth, args: args.first)
    end
  end
end
