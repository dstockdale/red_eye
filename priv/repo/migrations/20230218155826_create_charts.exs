defmodule RedEye.Repo.Migrations.CreateCharts do
  use Ecto.Migration

  def change do
    create table(:charts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :exchange, :string, null: false
      add :symbol, :string, null: false
      add :default_interval, :string, null: false
      add :earliest_timestamp, :utc_datetime

      timestamps()
    end

    create unique_index(:charts, [:exchange, :symbol])
  end
end
