defmodule RedEye.Repo.Migrations.AddTotpSecretToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :totp_secret, :string
    end

    create index(:users, [:totp_secret])
  end
end
