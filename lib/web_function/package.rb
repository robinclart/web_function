module WebFunction
  class Package
    def initialize(package)
      @package = package
    end

    def documentation
      Documentation.new(self)
    end

    def base_url
      @package["base_url"]
    end

    def name
      @package["name"]
    end

    def flags
      @package["flags"]
    end

    def docs
      @package["docs"]
    end

    def endpoints
      @package["endpoints"].map { |endpoint| Endpoint.new(endpoint) }
    end
  end
end
