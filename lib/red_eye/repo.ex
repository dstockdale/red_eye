defmodule RedEye.Repo do
  use Ecto.Repo,
    otp_app: :red_eye,
    adapter: Ecto.Adapters.Postgres
end
