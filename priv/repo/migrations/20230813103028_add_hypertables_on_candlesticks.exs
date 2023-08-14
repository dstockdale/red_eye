defmodule RedEye.Repo.Migrations.AddHypertablesOnCandlesticks do
  use Ecto.Migration

  def up do
    execute("SELECT create_hypertable('binance_spot_candles', 'timestamp')")
  end
end
