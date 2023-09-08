defmodule RedEye.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :red_eye,
    adapter: Ecto.Adapters.Postgres
end
