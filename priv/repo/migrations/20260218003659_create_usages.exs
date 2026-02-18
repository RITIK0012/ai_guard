defmodule AiGuard.Repo.Migrations.CreateUsages do
  use Ecto.Migration

  def change do
    create table(:usages) do
      add :api_key_id, references(:api_keys, on_delete: :delete_all)
      add :count, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:usages, [:api_key_id])
  end
end
