defmodule SpecGenerator do
  def generate(file_path) do
    generate(File.read(file_path), file_path)
  end

  defp generate({:error, _}, file_path), do: IO.puts("error file path")
  defp generate({:ok, source}, file_path) do
    File.write!(file_path, do_generate(source))
  end

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

  defp get_spec("  defp " <> body ), do: parse_method(body |> String.split(["(",")", "do"]))
  defp get_spec("  def " <> body ), do: parse_method(body |> String.split(["(",")", "do"]))

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

  defp parse_arguments([]), do: []
  defp parse_arguments([h|t]), do: parse_arguments(h, t, [])

  defp parse_arguments(" do" <> _, t, args_list), do: args_list
  defp parse_arguments("", t, args_list), do: args_list
  defp parse_arguments(_arg, [], args_list), do: args_list
  defp parse_arguments(arg, [h|t], args_list), do: parse_arguments(h, t, args_list ++ [arg])
end
