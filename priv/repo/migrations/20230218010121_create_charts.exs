defmodule RedEye.Repo.Migrations.CreateCharts do
  use Ecto.Migration

  def change do
    create table(:charts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :exchange, :string
      add :symbol, :string
      add :default_interval, :string

      timestamps()
    end

    create unique_index(:charts, [:exchange, :symbol])
  end
end
