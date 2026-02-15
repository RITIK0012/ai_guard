defmodule AiGuard.Dashboard.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dashboards" do
    field :title, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs, user_scope) do
    page
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> put_change(:user_id, user_scope.user.id)
  end
end
