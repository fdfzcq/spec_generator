defmodule SpecGenerator.Finder do
  def find_all(relative_path) do
    try do
      find_all_ex(relative_path)
    rescue
      _ -> raise "Invalid file path #{relative_path} given in the argument!"  
    end
  end

  defp find_all_ex(relative_path) do
    'ls -d '
      |> Kernel.++(String.to_charlist(relative_path))
      |> Kernel.++('**/*.ex')
      |> :os.cmd()
      |> :erlang.list_to_binary()
      |> parse_file_list()
  end

  defp parse_file_list(str), do: str
    |> String.trim
    |> String.split("\n")
end
