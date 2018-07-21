defmodule Example do
  defmodule Example.Foo do
    @spec func(a() :: any(), b() :: any()) :: any()
    def func(a, b), do: a + b
  end
end
defmodule ExampleB do
  @spec func(t() :: any()) :: any()
  def func(t), do: :ok
  defp function(_), do: "\n"
  @spec test(n() :: any()) :: any()
  def test(n) do
    n
  end
end
