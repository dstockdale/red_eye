defmodule RedEye.Repo.Migrations.CreateBinanceSpotCandles do
  use Ecto.Migration

  def change do
    create table(:binance_spot_candles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string, null: false
      add :high, :decimal, null: false
      add :low, :decimal, null: false
      add :open, :decimal, null: false
      add :close, :decimal, null: false
      add :volume, :decimal, null: false
      add :timestamp, :utc_datetime, null: false
      add :interval, :string, null: false
      add :kline_open_time, :utc_datetime, null: false
      add :kline_close_time, :utc_datetime, null: false
      add :quote_asset_volume, :decimal, null: false
      add :number_of_trades, :integer, null: false
      add :taker_buy_base_asset_volume, :decimal, null: false
      add :taker_buy_quote_asset_volume, :decimal, null: false

      timestamps()
    end

    create index(:binance_spot_candles, [:symbol])
    create unique_index(:binance_spot_candles, [:symbol, :timestamp, :interval])
  end
end
