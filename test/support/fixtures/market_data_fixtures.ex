defmodule RedEye.MarketDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RedEye.MarketData` context.
  """

  @doc """
  Generate a binance_spot_candle.
  """
  def binance_spot_candle_fixture(attrs \\ %{}) do
    {:ok, binance_spot_candle} =
      attrs
      |> Enum.into(%{
        close: "120.5",
        high: "120.5",
        kline_close_time: ~U[2023-02-14 14:12:00Z],
        kline_open_time: ~U[2023-02-14 14:12:00Z],
        low: "120.5",
        number_of_trades: 42,
        open: "120.5",
        quote_asset_volume: "120.5",
        symbol: "some symbol",
        taker_buy_base_asset_volume: "120.5",
        taker_buy_quote_asset_volume: "120.5",
        interval: "some interval",
        timestamp: ~U[2023-02-14 14:12:00Z],
        volume: "120.5"
      })
      |> RedEye.MarketData.create_binance_spot_candle()

    binance_spot_candle
  end
end
