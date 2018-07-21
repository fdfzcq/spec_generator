defmodule SpecGenerator.Parser do

  # TODO check if @spec already exist to avoid duplicates
  def parse(file_path) do
    #{:ok, _} = GenServer.start_link(SpecGenerator.Generator, [], name: :generator)
    code_str = File.read!(file_path)
    abstract = Code.string_to_quoted!(code_str)
    code_str_list = code_str
      |> String.split("\n")
      |> Enum.with_index
    parsed_abstract = abstract
      |> parse_abstract([])
      |> Enum.sort_by(fn {line, _} -> line end)
    output(parsed_abstract, code_str_list)
  end

  defp output(parse_abstract, code_str_list), do: output(parse_abstract, code_str_list, [])

  defp output(parse_abstract, code_str_list, generated)
  defp output(_, [], generated), do: {:ok, generated |> :lists.reverse |> Enum.join("\n")}
  defp output([{line_n, func}|at], [{code, line_n}|ct], generated), do:
    output(at, ct, [code|[indent(code) <> to_spec(func)|generated]])
  defp output(parse_abstract, [{code, _}|ct], generated), do: output(parse_abstract, ct, [code|generated])

  defp parse_abstract([], parsed), do: parsed
  defp parse_abstract([h|t], parsed), do: parse_abstract(t, parse_abstract(h, parsed))
  defp parse_abstract({:def, meta, cont}, parsed), do: [parse_fucntion({meta, cont})|parsed]
  defp parse_abstract({:defp, _meta, _cont}, parsed), do: parsed
  defp parse_abstract({_, _meta, cont}, parsed), do: parse_abstract(cont, parsed)
  defp parse_abstract({:do, cont}, parsed), do: parse_abstract(cont, parsed)
  defp parse_abstract(_, parsed), do: parsed

  defp parse_fucntion({meta, cont}) do
    line_n = Keyword.get(meta, :line)
    {func_name, args} = parse_function(cont)
    {line_n - 1, {func_name, args}}
  end
  defp parse_function([{func_name, _func_meta, args}|_]), do: {func_name, parse_args(args)}

  defp parse_args([]), do: []
  defp parse_args([h = {_, _, _}|t]), do: [parse_args(h)|parse_args(t)]
  defp parse_args([[]]), do: [{:list, nil}]
  defp parse_args({arg_name, _meta, value}), do: {arg_name, value}

  defp to_spec({func_name, args}), do: "@spec #{func_name}(" <> to_spec(args, "") <> ") :: any()"
  defp to_spec([], args), do: String.slice(args, 0..-3)
  defp to_spec([{arg_name, nil}|t], args), do: to_spec(t, args <> "#{arg_name}() :: any(), ")
  defp to_spec([{arg_name, value}|t], args), do: to_spec(t, args <> "#{arg_name}() :: #{value}, ")

  defp indent(code), do: code
   |> String.to_charlist()
   |> indent(0)
   |> duplicate_space()
  defp indent([?\s|t], n), do: indent(t, n + 1)
  defp indent(_, n), do: n

  defp duplicate_space(n), do: String.duplicate("\s", n)
end
