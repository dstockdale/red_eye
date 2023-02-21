defmodule RedEye.Repo.Migrations.CreateBinanceSymbols do
  use Ecto.Migration

  def change do
    create table(:binance_symbols, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string, null: false
      add :status, :string, null: false
      add :allow_trailing_stop, :boolean, default: false, null: false
      add :base_asset, :string, null: false
      add :base_asset_precision, :integer, null: false
      add :base_commission_precision, :integer, null: false
      add :is_margin_trading_allowed, :boolean, default: false, null: false
      add :is_spot_trading_allowed, :boolean, default: false, null: false
      add :quote_asset, :string, null: false
      add :quote_asset_precision, :integer, null: false
      add :quote_commission_precision, :integer, null: false
      add :quote_order_qty_allowed, :boolean, default: false, null: false
      add :quote_precision, :integer, null: false
      add :order_types, {:array, :string}, null: false, default: []
      add :permissions, {:array, :string}, null: false, default: []

      timestamps()
    end

    create unique_index(:binance_symbols, [:symbol])
    create index(:binance_symbols, [:base_asset])
    create index(:binance_symbols, [:quote_asset])
  end
end
