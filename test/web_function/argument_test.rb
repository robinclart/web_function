# frozen_string_literal: true

require "test_helper"

class WebFunctionArgumentTest < Minitest::Test
  def hash_payload
    {
      "name" => "limit",
      "type" => "integer",
      "hint" => "i32",
      "choices" => [10, 20],
      "flags" => [:optional],
      "docs" => "Pagination limit",
    }
  end

  def test_readers
    argument = WebFunction::Argument.new(hash_payload)
    assert_equal "limit", argument.name
    assert_equal "integer", argument.type
    assert_equal "i32", argument.hint
    assert_equal [10, 20], argument.choices
    assert_equal %w[optional], argument.flags
    assert_equal "Pagination limit", argument.docs
  end

  def test_choices_and_flags_empty_when_missing
    argument = WebFunction::Argument.new("name" => "n")
    assert_equal [], argument.choices
    assert_equal [], argument.flags
  end

  def test_docs_coerces_nil
    argument = WebFunction::Argument.new("name" => "n")
    assert_equal "", argument.docs
  end
end
