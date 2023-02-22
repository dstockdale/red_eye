defmodule RedEye.MarketDataTest do
  use RedEye.DataCase

  alias RedEye.MarketData

  describe "binance_spot_candles" do
    alias RedEye.MarketData.BinanceSpotCandle

    @invalid_attrs %{
      close: nil,
      high: nil,
      kline_close_time: nil,
      kline_open_time: nil,
      low: nil,
      number_of_trades: nil,
      open: nil,
      quote_asset_volume: nil,
      symbol: nil,
      taker_buy_base_asset_volume: nil,
      taker_buy_quote_asset_volume: nil,
      interval: nil,
      timestamp: nil,
      volume: nil
    }

    setup do
      binance_spot_candle = insert(:binance_spot_candle)
      {:ok, binance_spot_candle: binance_spot_candle}
    end

    test "list_binance_spot_candles/0 returns all binance_spot_candles", %{
      binance_spot_candle: binance_spot_candle
    } do
      assert MarketData.list_binance_spot_candles() == [binance_spot_candle]
    end

    test "create_binance_spot_candle/1 with valid data creates a binance_spot_candle" do
      valid_attrs = %{
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
        unix_time: ~U[2023-02-14 14:12:00Z] |> DateTime.to_unix(:millisecond),
        volume: "120.5"
      }

      assert {:ok, %BinanceSpotCandle{} = binance_spot_candle} =
               MarketData.create_binance_spot_candle(valid_attrs)

      assert binance_spot_candle.close == Decimal.new("120.5")
      assert binance_spot_candle.high == Decimal.new("120.5")
      assert binance_spot_candle.kline_close_time == ~U[2023-02-14 14:12:00Z]
      assert binance_spot_candle.kline_open_time == ~U[2023-02-14 14:12:00Z]
      assert binance_spot_candle.low == Decimal.new("120.5")
      assert binance_spot_candle.number_of_trades == 42
      assert binance_spot_candle.open == Decimal.new("120.5")
      assert binance_spot_candle.quote_asset_volume == Decimal.new("120.5")
      assert binance_spot_candle.symbol == "some symbol"
      assert binance_spot_candle.taker_buy_base_asset_volume == Decimal.new("120.5")
      assert binance_spot_candle.taker_buy_quote_asset_volume == Decimal.new("120.5")
      assert binance_spot_candle.interval == "some interval"
      assert binance_spot_candle.timestamp == ~U[2023-02-14 14:12:00Z]
      assert binance_spot_candle.volume == Decimal.new("120.5")
    end

    test "create_binance_spot_candle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MarketData.create_binance_spot_candle(@invalid_attrs)
    end

    # test "update_binance_spot_candle/2 with valid data updates the binance_spot_candle" do
    #   binance_spot_candle = binance_spot_candle_fixture()

    #   update_attrs = %{
    #     close: "456.7",
    #     high: "456.7",
    #     kline_close_time: ~U[2023-02-15 14:12:00Z],
    #     kline_open_time: ~U[2023-02-15 14:12:00Z],
    #     low: "456.7",
    #     number_of_trades: 43,
    #     open: "456.7",
    #     quote_asset_volume: "456.7",
    #     symbol: "some updated symbol",
    #     taker_buy_base_asset_volume: "456.7",
    #     taker_buy_quote_asset_volume: "456.7",
    #     interval: "some updated interval",
    #     timestamp: ~U[2023-02-15 14:12:00Z],
    #     volume: "456.7"
    #   }

    #   assert {:ok, %BinanceSpotCandle{} = binance_spot_candle} =
    #            MarketData.update_binance_spot_candle(binance_spot_candle, update_attrs)

    #   assert binance_spot_candle.close == Decimal.new("456.7")
    #   assert binance_spot_candle.high == Decimal.new("456.7")
    #   assert binance_spot_candle.kline_close_time == ~U[2023-02-15 14:12:00Z]
    #   assert binance_spot_candle.kline_open_time == ~U[2023-02-15 14:12:00Z]
    #   assert binance_spot_candle.low == Decimal.new("456.7")
    #   assert binance_spot_candle.number_of_trades == 43
    #   assert binance_spot_candle.open == Decimal.new("456.7")
    #   assert binance_spot_candle.quote_asset_volume == Decimal.new("456.7")
    #   assert binance_spot_candle.symbol == "some updated symbol"
    #   assert binance_spot_candle.taker_buy_base_asset_volume == Decimal.new("456.7")
    #   assert binance_spot_candle.taker_buy_quote_asset_volume == Decimal.new("456.7")
    #   assert binance_spot_candle.interval == "some updated interval"
    #   assert binance_spot_candle.timestamp == ~U[2023-02-15 14:12:00Z]
    #   assert binance_spot_candle.volume == Decimal.new("456.7")
    # end

    # test "update_binance_spot_candle/2 with invalid data returns error changeset" do
    #   binance_spot_candle = binance_spot_candle_fixture()

    #   assert {:error, %Ecto.Changeset{}} =
    #            MarketData.update_binance_spot_candle(binance_spot_candle, @invalid_attrs)

    #   assert binance_spot_candle == MarketData.get_binance_spot_candle!(binance_spot_candle.id)
    # end

    # test "delete_binance_spot_candle/1 deletes the binance_spot_candle" do
    #   binance_spot_candle = binance_spot_candle_fixture()

    #   assert {:ok, %BinanceSpotCandle{}} =
    #            MarketData.delete_binance_spot_candle(binance_spot_candle)

    #   assert_raise Ecto.NoResultsError, fn ->
    #     MarketData.get_binance_spot_candle!(binance_spot_candle.id)
    #   end
    # end

    # test "change_binance_spot_candle/1 returns a binance_spot_candle changeset" do
    #   binance_spot_candle = binance_spot_candle_fixture()
    #   assert %Ecto.Changeset{} = MarketData.change_binance_spot_candle(binance_spot_candle)
    # end
  end
end
