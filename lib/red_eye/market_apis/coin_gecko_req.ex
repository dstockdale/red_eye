defmodule RedEye.MarketApis.CoinGeckoReq do
  @moduledoc """
  The API code ot fetch the latest symbols from Binance
  """
  @base_url "https://api.coingecko.com"

  def base_url do
    Req.new(base_url: @base_url)
  end

  def fetch_stable_coins() do
    params = %{
      vs_currency: "usd",
      # category: "stablecoins",
      order: "market_cap_desc",
      per_page: "250",
      page: "1",
      sparkline: "false",
      locale: "en"
    }

    Req.get!(base_url(), url: "/api/v3/coins/markets", params: params)
  end

  def fetch_global_market_cap do
    Req.get!(base_url(), url: "/api/v3/global")
  end

  def map_global_market_cap(%{body: body}) do
    Enum.map(body, fn item -> item["market_cap"] end)
    |> Enum.sum()
    |> trunc()
  end
end
