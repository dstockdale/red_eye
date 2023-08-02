defmodule RedEye.Cache do
  use Nebulex.Cache,
    otp_app: :red_eye,
    adapter: Nebulex.Adapters.Local
end
