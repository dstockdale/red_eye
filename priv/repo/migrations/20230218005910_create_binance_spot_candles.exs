defmodule RedEye.Repo.Migrations.CreateBinanceSpotCandles do
  use Ecto.Migration

  def up do
    create table(:binance_spot_candles, primary_key: false) do
      add :timestamp, :utc_datetime, null: false, primary_key: true
      add :symbol, :string, null: false, primary_key: true
      add :interval, :string, null: false, primary_key: true
      add :unix_time, :bigint, null: false
      add :high, :decimal, null: false
      add :low, :decimal, null: false
      add :open, :decimal, null: false
      add :close, :decimal, null: false
      add :volume, :decimal, null: false
      add :kline_open_time, :utc_datetime, null: false
      add :kline_close_time, :utc_datetime, null: false
      add :quote_asset_volume, :decimal, null: false
      add :number_of_trades, :integer, null: false
      add :taker_buy_base_asset_volume, :decimal, null: false
      add :taker_buy_quote_asset_volume, :decimal, null: false

      timestamps()
    end

    execute("SELECT create_hypertable('binance_spot_candles', 'timestamp')")
    create index(:binance_spot_candles, [:symbol])
    create index(:binance_spot_candles, [:unix_time])
    create unique_index(:binance_spot_candles, [:symbol, :timestamp, :interval])
  end

  def down do
    drop table(:binance_spot_candles)
    drop index(:binance_spot_candles, [:symbol])
    drop unique_index(:binance_spot_candles, [:symbol, :timestamp, :interval])
  end
end
