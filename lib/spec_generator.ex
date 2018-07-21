defmodule SpecGenerator do

  alias SpecGenerator.Finder
  alias SpecGenerator.Parser

  def process([]), do: process(Finder.find_all("./"))
  def process(args) do
    args
    |> Enum.map(&String.split(&1, ","))
    |> List.flatten
    |> Enum.map(&do_process/1)
  end

  defp do_process(file) do
    {:ok, parsed} = Parser.parse(file)
    File.write!(file, parsed)
  end
end
