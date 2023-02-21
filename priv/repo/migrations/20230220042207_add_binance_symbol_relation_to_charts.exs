defmodule RedEye.Repo.Migrations.AddBinanceSymbolRelationToCharts do
  use Ecto.Migration

  def change do
    alter table(:charts) do
      add :binance_symbol_id,
          references(:binance_symbols, on_delete: :delete_all, type: :binary_id)

      remove :symbol, :string, null: false
      remove :default_interval, :string, null: false
    end

    create index(:charts, [:binance_symbol_id])
  end
end
