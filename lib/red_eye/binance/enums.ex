defmodule RedEye.Binance.Enums do
  @spec intervals :: %{optional(<<_::16, _::_*8>>) => <<_::40, _::_*8>>}
  @doc """
  Returns a Map of binance intervals as the keys and their SQL INTERVAL equivalents
  because that's how we tend to use them and you can translate them.
  """
  def intervals do
    %{
      "1m" => "1 minute",
      "3m" => "3 minutes",
      "5m" => "5 minutes",
      "15m" => "15 minutes",
      "30m" => "30 minutes",
      "1h" => "1 hour",
      "2h" => "2 hours",
      "4h" => "4 hours",
      "6h" => "6 hours",
      "8h" => "8 hours",
      "12h" => "12 hours",
      "1d" => "1 day",
      "3d" => "3 days",
      "1w" => "1 week",
      "1M" => "1 month"
    }
  end
end
