# frozen_string_literal: true

require "excon"
require "json"
require "uri"

require_relative "web_function/version"
require_relative "web_function/client"
require_relative "web_function/package"
require_relative "web_function/endpoint"
require_relative "web_function/argument"
require_relative "web_function/documentation"

module WebFunction
  class Error < StandardError; end
end
