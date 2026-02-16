defmodule AiGuard.Api.Moderation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "moderations" do
    field :text, :string
    field :result, :string
    field :api_key, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(moderation, attrs, user_scope) do
    moderation
    |> cast(attrs, [:text, :result, :api_key])
    |> validate_required([:text, :result, :api_key])
    |> put_change(:user_id, user_scope.user.id)
  end
end
