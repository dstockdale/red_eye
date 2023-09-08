defmodule RedEye.Cache do
  @moduledoc """
  Module for Nebulex caching
  """
  use Nebulex.Cache,
    otp_app: :red_eye,
    adapter: Nebulex.Adapters.Local
end
