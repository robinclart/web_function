# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "web_function"

require "minitest/autorun"

module WebFunctionTestHelpers
  def with_http_client_returning(status:, body:)
    request = nil
    original_http_client = WebFunction::Endpoint.http_client

    WebFunction::Endpoint.http_client = Proc.new do |url, headers, args|
      request = { url: url, headers: headers, args: args }
      [status, body]
    end

    yield

    request
  ensure
    WebFunction::Endpoint.http_client = original_http_client
  end
end

class Minitest::Test
  include WebFunctionTestHelpers
end
