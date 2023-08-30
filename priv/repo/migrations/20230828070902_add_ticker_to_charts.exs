defmodule RedEye.Repo.Migrations.AddTickerToCharts do
  use Ecto.Migration

  def change do
    alter table(:charts) do
      add :ticker, :map, default: "{}"
    end
  end
end
