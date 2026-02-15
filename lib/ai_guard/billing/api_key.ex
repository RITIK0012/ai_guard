defmodule AiGuard.Billing.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_keys" do
    field :key, :string
    field :revoked_at, :utc_datetime
    belongs_to :user, AiGuard.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(api_key, attrs, _scope \\ nil) do
  api_key
  |> cast(attrs, [:user_id, :revoked_at])
  |> validate_required([:user_id])
  |> put_change(:key, generate_key())
end

defp generate_key do
  :crypto.strong_rand_bytes(32)
  |> Base.url_encode64(padding: false)
end

end
