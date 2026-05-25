# frozen_string_literal: true

require "excon"
require "json"
require "uri"

require_relative "web_function/version"
require_relative "web_function/client"
require_relative "web_function/package"
require_relative "web_function/endpoint"
require_relative "web_function/argument"
require_relative "web_function/attribute"
require_relative "web_function/documented_error"
require_relative "web_function/pipeline"
require_relative "web_function/promise"

module WebFunction
  class Error < StandardError
    attr_reader :code, :details

    def initialize(message = nil, code: self.class.name, details: nil)
      super(message)
      @code = code
      @details = details
    end
  end

  class UnresolvedPromiseError < Error
  end

  class UnexpectedStatusCodeError < Error
  end

  class JsonParseError < Error
  end

  class BadRequestError < Error
  end
end
