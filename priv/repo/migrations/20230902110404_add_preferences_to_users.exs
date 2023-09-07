defmodule RedEye.Repo.Migrations.AddPreferencesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :preferences, :map, default: %{}
    end
  end
end
