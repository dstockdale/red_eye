defmodule RedEye.Repo.Migrations.AddTotpConfirmedAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :totp_confirmed_at, :naive_datetime
    end
  end
end
