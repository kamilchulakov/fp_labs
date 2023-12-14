defmodule ExampleBench do
  use BencheeDsl.Benchmark
  alias Stream4

  config(time: 3)

  formatter(Benchee.Formatters.Markdown,
    file: Path.expand("BENCH.md", __DIR__)
  )

  inputs(%{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  })

  defp sum(i, acc), do: i + acc

  job foldr(input) do
    input |> Stream4.foldr(0, &sum/2)
  end

  job foldl(input) do
    input |> Stream4.foldl(0, &sum/2)
  end
end
