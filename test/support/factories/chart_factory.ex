defmodule RedEye.ChartFactory do
  @moduledoc """
  Factory for Chart schema
  """
  defmacro __using__(_opts) do
    quote do
      def chart_factory do
        %RedEye.Charts.Chart{
          exchange: "binance",
          binance_symbol: build(:binance_symbol)
        }
      end
    end
  end
end
