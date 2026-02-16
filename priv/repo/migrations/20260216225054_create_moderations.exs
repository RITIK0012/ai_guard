defmodule AiGuard.Repo.Migrations.CreateModerations do
  use Ecto.Migration

  def change do
    create table(:moderations) do
      add :text, :string
      add :result, :string
      add :api_key, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:moderations, [:user_id])
  end
end
