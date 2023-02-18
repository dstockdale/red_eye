defmodule RedEye.Factory do
  use ExMachina.Ecto, repo: RedEye.Repo
  use RedEye.BinanceSpotCandleFactory
end
