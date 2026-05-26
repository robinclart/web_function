# frozen_string_literal: true

require "test_helper"

class AutomaticCompressionTest < Minitest::Test
  def test_automatic_compression_headers
    with_http_client_returning(status: 200, body: "{}") do
      WebFunction::Endpoint.invoke("https://api.test/endpoint")
    end
    
    # Verify that Accept-Encoding is present by default
    request = with_http_client_returning(status: 200, body: "{}") do
      WebFunction::Endpoint.invoke("https://api.test/endpoint")
    end
    
    assert_includes request[:headers], "Accept-Encoding"
    assert_includes request[:headers]["Accept-Encoding"], "gzip"
    assert_includes request[:headers]["Accept-Encoding"], "deflate"
    
    # Verify it doesn't have br unless Brotli is defined
    unless defined?(::Brotli)
      refute_includes request[:headers]["Accept-Encoding"], "br"
    end
  end

  def test_automatic_compression_headers_with_brotli
    # Mocking Brotli definition
    Object.const_set(:Brotli, Module.new) unless defined?(::Brotli)
    
    request = with_http_client_returning(status: 200, body: "{}") do
      WebFunction::Endpoint.invoke("https://api.test/endpoint")
    end
    
    assert_includes request[:headers]["Accept-Encoding"], "br"
  ensure
    # Cleanup mock Brotli if we created it
    Object.send(:remove_const, :Brotli) if defined?(::Brotli) && !ENV['REAL_BROTLI']
  end
end
