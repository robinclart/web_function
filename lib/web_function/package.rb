# frozen_string_literal: true

module WebFunction
  class Package
    def initialize(package)
      @package = package
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
      unless @package["endpoints"].is_a?(Array)
        return []
      end

      @package["endpoints"].map { |endpoint| Endpoint.new(endpoint) }
    end

    def errors
      unless @package["errors"].is_a?(Array)
        return []
      end

      @package["errors"].map { |error| DocumentedError.new(error) }
    end
  end
end
