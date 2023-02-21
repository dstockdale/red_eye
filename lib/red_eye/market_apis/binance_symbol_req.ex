defmodule RedEye.MarketApis.BinanceSymbolReq do
  @moduledoc """
  The API code ot fetch the latest symbols from Binance
  """
  @base_url "https://api.binance.com"

  def base_url do
    Req.new(base_url: @base_url)
  end

  def fetch do
    Req.get!(base_url(), url: "/api/v3/exchangeInfo").body
  end

  def map(response) do
    response
    |> Map.get("symbols", [])
    |> Enum.map(fn data ->
      %{
        symbol: data["symbol"],
        status: data["status"],
        allow_trailing_stop: data["allowTrailingStop"],
        base_asset: data["baseAsset"],
        base_asset_precision: data["baseAssetPrecision"],
        base_commission_precision: data["baseCommissionPrecision"],
        is_margin_trading_allowed: data["isMarginTradingAllowed"],
        is_spot_trading_allowed: data["isSpotTradingAllowed"],
        quote_asset: data["quoteAsset"],
        quote_asset_precision: data["quoteAssetPrecision"],
        quote_commission_precision: data["quoteCommissionPrecision"],
        quote_order_qty_allowed: data["quoteOrderQtyMarketAllowed"],
        quote_precision: data["quotePrecision"],
        order_types: data["orderTypes"],
        permissions: data["permissions"],
        inserted_at: timestamp(),
        updated_at: timestamp()
      }
    end)
  end

  defp timestamp do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
