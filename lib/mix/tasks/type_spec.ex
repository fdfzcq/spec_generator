defmodule Mix.Tasks.TypeSpec do

  defmodule Generate do
    use Mix.Task

    def run(args) do
      SpecGenerator.process(args)
    end
  end
end
