# frozen_string_literal: true

require "excon"
require "json"
require "uri"

require_relative "web_function/version"
require_relative "web_function/client"
require_relative "web_function/package"
require_relative "web_function/endpoint"
require_relative "web_function/argument"

module WebFunction
  class Error < StandardError
    attr_reader :code, :details

    def initialize(message = nil, code: nil, details: nil)
      super(message)
      @code = code
      @details = details
    end
  end
end
