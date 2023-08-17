defmodule RedEyeWeb.ChartControllerTest do
  use RedEyeWeb.ConnCase

  setup %{conn: conn} do
    binance_spot_candle = insert(:binance_spot_candle)

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     binance_spot_candle: binance_spot_candle}
  end

  describe "index candles" do
    test "lists all candlesticks", %{conn: conn, binance_spot_candle: binance_spot_candle} do
      conn =
        get(conn, ~p"/api/charts", symbol: "BTCUSDT", interval: "1 hour", chart_type: "candle")

      result = json_response(conn, 200) |> Jason.decode!() |> List.first()

      assert result["volume"] == binance_spot_candle.volume |> Decimal.to_string()
      assert result["open"] == binance_spot_candle.open |> Decimal.to_string()
      assert result["close"] == binance_spot_candle.close |> Decimal.to_string()
      assert result["high"] == binance_spot_candle.high |> Decimal.to_string()
      assert result["low"] == binance_spot_candle.low |> Decimal.to_string()
    end
  end

  # describe "index swings" do
  #   test "lists all swings", %{conn: conn} do
  #     conn =
  #       get(conn, ~p"/api/charts", symbol: "BTCUSDT", interval: "1 hour", chart_type: "swing")

  #     assert json_response(conn, 200) == []
  #   end
  # end
end
