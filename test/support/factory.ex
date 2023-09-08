defmodule RedEye.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: RedEye.Repo
  use RedEye.BinanceSpotCandleFactory
  use RedEye.BinanceSymbolFactory
  use RedEye.ChartFactory
end
