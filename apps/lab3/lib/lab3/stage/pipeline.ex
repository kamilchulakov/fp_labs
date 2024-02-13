defmodule Lab3.Stage.Pipeline do
  def pipeline(producer: producer, buffer: buffer, processors: processors, consumer: consumer) do
    children = [
      to_child_spec(producer),
      to_child_spec(buffer),
      to_child_spec(consumer) |
      to_child_specs(processors)
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  defp to_child_spec(module_spec = {_, opts}),
    do: Supervisor.child_spec(module_spec, id: opts[:name])

  defp to_child_specs(modules),
    do: Enum.map(modules, &to_child_spec/1)
end
