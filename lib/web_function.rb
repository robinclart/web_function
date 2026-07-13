# frozen_string_literal: true

require "excon"
require "json"
require "uri"

require_relative "web_function/version"
require_relative "web_function/request"
require_relative "web_function/client"
require_relative "web_function/flaggable"
require_relative "web_function/package"
require_relative "web_function/endpoint"
require_relative "web_function/argument"
require_relative "web_function/attribute"
require_relative "web_function/object_schema"
require_relative "web_function/documented_error"
require_relative "web_function/pipeline"
require_relative "web_function/promise"
require_relative "web_function/type"
require_relative "web_function/utils"

module WebFunction
  # A base error class for WebFunction. All errors inherit from this class.
  #
  # @api private
  #
  class Error < StandardError
    attr_reader :code, :details

    def initialize(message = nil, code: self.class.error_code, details: nil)
      super(message)
      @code = code
      @details = details
    end

    # Returns the error code for the error. Used as default error code if no code is provided.
    #
    # @return [String] The error code
    #
    def self.error_code
      name.sub(/^WebFunction::/, "WFN_")
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .upcase
    end
  end

  UnresolvedPromiseError = Class.new(Error)
  UnexpectedStatusCodeError = Class.new(Error)
  JsonParseError = Class.new(Error)
  BadRequestError = Class.new(Error)
end
