defmodule SpecGeneratorTest do
  use ExUnit.Case
  doctest SpecGenerator

  test "greets the world" do
    assert SpecGenerator.hello() == :world
  end
end
