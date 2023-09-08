defmodule RedEye.BinanceSymbolFactory do
  @moduledoc """
  Factory for BinanceSymbol
  """
  defmacro __using__(_opts) do
    quote do
      def binance_symbol_factory do
        %RedEye.MarketData.BinanceSymbol{
          symbol: "BTCUSDT",
          status: "TRADING",
          allow_trailing_stop: true,
          base_asset: "BTC",
          base_asset_precision: 8,
          base_commission_precision: 8,
          is_margin_trading_allowed: true,
          is_spot_trading_allowed: true,
          quote_asset: "USDT",
          quote_asset_precision: 8,
          quote_commission_precision: 8,
          quote_order_qty_allowed: true,
          quote_precision: 8,
          order_types: ~w(LIMIT LIMIT_MAKER MARKET STOP_LOSS_LIMIT TAKE_PROFIT_LIMIT),
          permissions: ~w(SPOT MARGIN TRD_GRP_004 TRD_GRP_005 TRD_GRP_006)
        }
      end
    end
  end
end
