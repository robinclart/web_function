# frozen_string_literal: true

require "test_helper"

class WebFunctionPackageTest < Minitest::Test
  def sample_package
    {
      "base_url" => "https://api.webfunction.com/",
      "name" => "Web Function",
      "flags" => %w[alpha beta],
      "docs" => "Package docs",
      "endpoints" => [
        { "name" => "hello", "docs" => "Say hi" },
        "not-a-hash",
        { "docs" => "missing name" },
      ],
      "errors" => [
        { "code" => "NOT_FOUND", "docs" => "Missing" },
        "bad",
        { "docs" => "no code" },
      ],
    }
  end

  def test_accessors
    package = WebFunction::Package.new(sample_package)
    assert_equal "https://api.webfunction.com/", package.base_url
    assert_equal "Web Function", package.name
    assert_equal "Package docs", package.docs
  end

  def test_flags_empty_when_missing_or_not_array
    assert_equal [], WebFunction::Package.new({}).flags
    assert_equal [], WebFunction::Package.new("flags" => {}).flags
  end

  def test_flags_returns_array_from_payload
    package = WebFunction::Package.new("flags" => %w[x y])
    assert_equal %w[x y], package.flags
  end

  def test_endpoints_skips_invalid_entries
    package = WebFunction::Package.new(sample_package)
    names = package.endpoints.compact.map(&:name)
    assert_equal ["hello"], names
  end

  def test_endpoints_empty_when_missing_or_not_array
    assert_equal [], WebFunction::Package.new({}).endpoints
    assert_equal [], WebFunction::Package.new("endpoints" => {}).endpoints
  end

  def test_errors_skips_invalid_entries
    package = WebFunction::Package.new(sample_package)
    codes = package.errors.compact.map(&:code)
    assert_equal ["NOT_FOUND"], codes
  end

  def test_errors_empty_when_missing_or_not_array
    assert_equal [], WebFunction::Package.new({}).errors
    assert_equal [], WebFunction::Package.new("errors" => {}).errors
  end

  def test_docs_coerces_to_string
    assert_equal "", WebFunction::Package.new({}).docs
    assert_equal "123", WebFunction::Package.new("docs" => 123).docs
  end
end
