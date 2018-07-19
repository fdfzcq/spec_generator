defmodule SpecGenerator.Parser do
  def parse(file_path) do
    {:ok, _} = GenServer.start_link(SpecGenerator.Generator, [], name: :generator)
    code_str = File.read!(file_path)
    abstract = Code.string_to_quoted!(code_str)
    code_str_list = code_str |> String.split("\n")
    parsed_abstract = parse_abstract(abstract, [])
 #   generated = parse({code_str_list, abstract}, "")
  end

  defp parse_abstract([], parsed), do: parsed
  defp parse_abstract([h|t], parsed), do: parse_abstract(t, parse_abstract(h, parsed))
  defp parse_abstract({:defmodule, _meta, cont}, parsed), do: parse_abstract(cont, parsed)
  defp parse_abstract({:def, meta, cont}, parsed), do: [parse_fucntion({meta, cont})|parsed]
  defp parse_abstract({:defp, _meta, _cont}, parsed), do: parsed

  defp parse_fucntion({meta, cont}) do
    line_n = Keyword.get(meta, :line)
    {func_name, args} = parse_function(cont)
    {line_n, {func_name, args}}
  end

  defp parse_function([{func_name, _func_meta, args}]), do: {func_name, parse_args(args)}

  defp parse_args([]), do: []
  defp parse_args([h|t]), do: [parse_args(h)|parse_args(t)]
  defp parse_args({arg_name, _meta, nil}), do: {arg_name, nil}
  defp parse_args({arg_name, _meta, value}), do: {arg_name, value}
end
