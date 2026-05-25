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
      unless @package["flags"].is_a?(Array)
        return []
      end

      @package["flags"].each do |flag|
        flag.to_s
      end
    end

    def docs
      @package["docs"].to_s
    end

    def endpoints
      unless @package["endpoints"].is_a?(Array)
        return []
      end

      @package["endpoints"].map do |endpoint|
        unless endpoint.is_a?(Hash)
          next
        end

        unless endpoint["name"]
          next
        end

        Endpoint.new(endpoint)
      end
    end

    def errors
      unless @package["errors"].is_a?(Array)
        return []
      end

      @package["errors"].map do |error|
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
