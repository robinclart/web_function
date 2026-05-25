# frozen_string_literal: true

require "test_helper"

class WebFunctionAttributeTest < Minitest::Test
  def hash_payload
    {
      "name" => "state",
      "type" => "array",
      "hint" => nil,
      "values" => %w[open closed],
      "flags" => [:nullable],
      "docs" => "Current state",
    }
  end

  def test_readers
    attribute = WebFunction::Attribute.new(hash_payload)
    assert_equal "state", attribute.name
    assert_equal "array", attribute.type
    refute attribute.hint
    assert_equal %w[open closed], attribute.values
    assert_equal %w[nullable], attribute.flags
    assert_equal "Current state", attribute.docs
  end

  def test_values_and_flags_empty_when_missing
    attribute = WebFunction::Attribute.new("name" => "n")
    assert_equal [], attribute.values
    assert_equal [], attribute.flags
  end

  def test_docs_coerces_nil
    attribute = WebFunction::Attribute.new("name" => "n")
    assert_equal "", attribute.docs
  end
end
