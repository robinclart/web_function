# frozen_string_literal: true

require "test_helper"

class WebFunctionEndpointTest < Minitest::Test
  def endpoint_hash
    {
      "name" => "do-thing",
      "returns" => [:json, "text"],
      "hints" => [:fast],
      "flags" => [:beta],
      "group" => "main",
      "docs" => "Does a thing",
      "arguments" => [
        { "name" => "id", "type" => "string", "hint" => "id", "choices" => [1, 2], "flags" => [:req], "docs" => "Arg docs" },
        "skip",
        { "name" => nil },
      ],
      "attributes" => [
        { "name" => "status", "type" => "string", "hint" => nil, "values" => [1], "flags" => [], "docs" => "" },
      ],
      "errors" => [
        { "code" => "X", "docs" => "e" },
      ],
    }
  end

  def test_instance_readers
    ep = WebFunction::Endpoint.new(endpoint_hash)
    assert_equal "do-thing", ep.name
    assert_equal %w[json text], ep.returns
    assert_equal %w[fast], ep.hints
    assert_equal %w[beta], ep.flags
    assert_equal "main", ep.group
    assert_equal "Does a thing", ep.docs
  end

  def test_returns_hints_flags_empty_when_missing
    ep = WebFunction::Endpoint.new({ "name" => "n" })
    assert_equal [], ep.returns
    assert_equal [], ep.hints
    assert_equal [], ep.flags
  end

  def test_arguments_and_attributes_and_errors
    ep = WebFunction::Endpoint.new(endpoint_hash)
    assert_equal ["id"], ep.arguments.compact.map(&:name)
    assert_equal ["status"], ep.attributes.compact.map(&:name)
    assert_equal ["X"], ep.errors.compact.map(&:code)
  end

  def test_arguments_empty_when_not_array
    ep = WebFunction::Endpoint.new("name" => "n", "arguments" => {})
    assert_equal [], ep.arguments
  end

  def test_invoke_nil_args_becomes_empty_hash
    with_http_client_returning(status: 200, body: "{}") do
      WebFunction::Endpoint.invoke("https://x", args: nil)
    end
  end

  def test_invoke_success_parses_json
    with_http_client_returning(status: 200, body: '{"ok":true,"n":3}') do
      out = WebFunction::Endpoint.invoke("https://x", args: {})
      assert_equal true, out["ok"]
      assert_equal 3, out["n"]
    end
  end

  def test_invoke_bad_request_triple
    body = JSON.generate(["CODE_HERE", "human", { "x" => 1 }])
    with_http_client_returning(status: 400, body: body) do
      err = assert_raises(WebFunction::Error) do
        WebFunction::Endpoint.invoke("https://x")
      end
      assert_equal "CODE_HERE", err.code
      assert_equal "human", err.message
      assert_equal({ "x" => 1 }, err.details)
    end
  end

  def test_invoke_bad_request_string_body
    with_http_client_returning(status: 400, body: JSON.generate("plain")) do
      err = assert_raises(WebFunction::Error) do
        WebFunction::Endpoint.invoke("https://x")
      end
      assert_equal "BAD_REQUEST", err.code
      assert_equal "plain", err.message
      assert_nil err.details
    end
  end

  def test_invoke_bad_request_non_triple_array
    body = JSON.generate([1, 2])
    with_http_client_returning(status: 400, body: body) do
      err = assert_raises(WebFunction::Error) do
        WebFunction::Endpoint.invoke("https://x")
      end
      assert_equal "BAD_REQUEST", err.code
      assert_equal "Bad request", err.message
      assert_equal [1, 2], err.details[:body]
    end
  end

  def test_invoke_unexpected_status
    with_http_client_returning(status: 500, body: "{}") do
      err = assert_raises(WebFunction::Error) do
        WebFunction::Endpoint.invoke("https://x")
      end
      assert_equal "UNEXPECTED_STATUS_CODE", err.code
      assert_match(/500/, err.message)
    end
  end

  def test_invoke_json_parse_error
    with_http_client_returning(status: 200, body: "not json {") do
      err = assert_raises(WebFunction::Error) do
        WebFunction::Endpoint.invoke("https://x")
      end
      assert_equal "JSON_PARSE_ERROR", err.code
    end
  end

  def test_docs_coerces_nil
    ep = WebFunction::Endpoint.new("name" => "n")
    assert_equal "", ep.docs
  end
end
