defmodule ParserTest do
  alias SpecGenerator.Parser
  use ExUnit.Case

  @example_path "examples/example.ex"
  @generated_path "examples/generated.ex"

  test "parse the example" do
    {:ok, parsed} = Parser.parse(@example_path)
    expected = File.read!(@generated_path)
    assert parsed == expected
  end
end
