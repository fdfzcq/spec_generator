# SpecGenerator

A tool that can be used for generating dummy type spec documentations on given modules.

## Usage

```elixir
mix type_spec.generate
# this will annotate all .ex files with type spec documentations.
```
OR

you can specific file names, e.g. :
```elixir
mix type_spec.generate "spec_generator.ex,test.ex"
```

## Examples

```elixir
@spec generate(file_path()) :: any() #generated
  def generate(file_path) do
    generate(File.read(file_path), file_path)
  end

@spec generate({error(), _()}, file_path()) :: any() #generated
  defp generate({:error, _}, file_path), do: IO.puts("error file path")
  defp generate({:ok, source}, file_path) do
    File.write!(file_path, do_generate(source))
  end
```
## WIP: next step

Parse AST and generate specs according to type specified.
