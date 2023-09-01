defmodule RedEye.MarketApis.BinanceSpot do
  @moduledoc """
  For importing candle data from Binance Spot Market
  """
  @base_url "https://www.binance.com"

  @spec base_url :: Req.Request.t()
  def base_url do
    Req.new(base_url: @base_url)
  end

  @spec fetch(integer(), String.t(), String.t()) :: {:ok, list()} | {:error, map()}
  def fetch(start_time, symbol, interval) do
    params = [
      symbol: symbol,
      startTime: to_string(start_time),
      interval: interval,
      limit: 1000
    ]

    case Req.get(base_url(), url: "/api/v3/klines", params: params) do
      {:ok, response} ->
        case response.status do
          200 ->
            response.body

          408 ->
            []

          _ ->
            raise "Kaboom!"
        end

      {:error, response} ->
        raise IO.inspect(response)
    end
  end
end
