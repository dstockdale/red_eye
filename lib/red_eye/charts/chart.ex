defmodule RedEye.Charts.Chart do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "charts" do
    field :default_interval, :string
    field :exchange, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(chart, attrs) do
    chart
    |> cast(attrs, [:exchange, :symbol, :default_interval])
    |> validate_required([:exchange, :symbol, :default_interval])
  end
end
