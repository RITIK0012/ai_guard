defmodule AiGuard.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :key, :string
      add :revoked_at, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:api_keys, [:user_id])
    create unique_index(:api_keys, [:key])
  end
end
