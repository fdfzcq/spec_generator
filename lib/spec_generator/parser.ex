defmodule SpecGenerator.Parser do
  def parse(file_path) do
    {:ok, _} = GenServer.start_link(SpecGenerator.Generator, [], name: :generator)
    code_str = File.read!(file_path)
    abstract = Code.string_to_quoted!(code_str)
    parse({code_str, abstract}, "", &continue_parse/2)
  end

  defp parse({code_str, abstract}, generated, function) do
    #TBC
  end
end
