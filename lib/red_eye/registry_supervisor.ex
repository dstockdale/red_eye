defmodule RedEye.RegistrySupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: RedEye.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
