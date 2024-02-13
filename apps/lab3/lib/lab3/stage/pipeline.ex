defmodule Lab3.Stage.Pipeline do
  @moduledoc """
  Pipeline is a cool abstraction.
  """

  def pipeline(producer: producer, buffer: buffer, processors: processors, consumer: consumer) do
    children = [
      to_child_spec(producer, buffer: name(buffer)),
      to_child_spec(buffer),
      to_child_spec(consumer)
      | to_child_specs(processors, buffer: name(buffer), consumer: name(consumer))
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  defp to_child_spec(module_spec),
    do: Supervisor.child_spec(module_spec, id: name(module_spec))

  defp to_child_spec({module, opts}, other_opts),
    do: Supervisor.child_spec({module, Keyword.merge(opts, other_opts)}, id: opts[:name])

  defp to_child_specs(modules, opts),
    do: Enum.map(modules, &to_child_spec(&1, opts))

  defp name({_, opts}), do: opts[:name]
end
