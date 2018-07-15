defmodule SpecGenerator do

  alias SpecGenerator.Finder

  @spec process([]()) :: any()
  def process([]), do: process(Finder.find_all("./"))
  def process(args) do
    args
    |> Enum.map(&String.split(&1, ","))
    |> List.flatten
    |> Enum.map(&generate/1)
  end

  ### TODO: extract into separate files, use AST instead of parsing plain text file ####

  @spec generate(file_path()) :: any()
  def generate(file_path) do
    generate(File.read(file_path), file_path)
  end

  @spec generate({error(), _()}, file_path()) :: any()
  defp generate({:error, _}, file_path), do: IO.puts("error file path")
  defp generate({:ok, source}, file_path) do
    File.write!(file_path, do_generate(source))
  end

  @spec (_generate()) :: any()
  defp do_generate(source) do
    list = source
           |> String.split("\n")
           |> Enum.with_index
    {new_list, list} = list
                       |> Enum.reduce({[],list}, &insert_spec(&1, &2))
    generated = new_list |> Enum.join("\n")
    IO.puts generated
    #Code.eval_string(generated)
    generated
  end

  @spec insert_spec({code() = "  def()" <> _(), index()}, {new_list(), list}()) :: any()
  defp insert_spec({code = "  def" <> _, index}, {new_list, list}) do
    {prev_string, _} = Enum.at(list, index-1)
    case String.trim(prev_string) do
      "@spec" <> _ -> {new_list ++ [code], list}
      "" -> {new_list ++ [get_spec(code)] ++ [code], list}
      "\"\"\"" -> {new_list ++ [get_spec(code)] ++ [code], list}
      "#" <> _ -> {new_list ++ [get_spec(code)] ++ [code], list}
      _ -> {new_list ++ [code], list}
    end
  end
  defp insert_spec({code, _index}, {new_list, list}) do
    {new_list ++ [code], list}
  end

  @spec get_spec(()"  defp() " <> body ()) :: any()
  defp get_spec("  defp " <> body ), do: parse_method(body |> String.split(["(",")", "do"]))
  defp get_spec("  def " <> body ), do: parse_method(body |> String.split(["(",")", "do"]))

  @spec parse_method(parsed()) :: any()
  defp parse_method(parsed) do
    method_name = Enum.at(parsed, 0) |> String.replace([", ", " "], "")
    arguments = Enum.at(parsed, 1)
    case arguments do
      nil -> "  @spec #{method_name} :: any()"
      ":" <> _ -> "  @spec #{method_name} :: any()"
      " do" <> _ -> "  @spec #{method_name} :: any()"
      args -> arguments = Regex.replace(~r/\W+\s/, arguments |> String.replace(":", ""), "()\\0")
              #arguments = Regex.replace(~r/\w+/, arguments, "any")
              "  @spec #{method_name}(" <> arguments <> ("()) :: any()")
    end
  end

  @spec parse_arguments([]()) :: any()
  defp parse_arguments([]), do: []
  defp parse_arguments([h|t]), do: parse_arguments(h, t, [])

  @spec parse_arguments(()" ()) :: any()
  defp parse_arguments(" do" <> _, t, args_list), do: args_list
  defp parse_arguments("", t, args_list), do: args_list
  defp parse_arguments(_arg, [], args_list), do: args_list
  defp parse_arguments(arg, [h|t], args_list), do: parse_arguments(h, t, args_list ++ [arg])
end
