defmodule AiGuard.Billing.Usage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "usages" do
    field :count, :integer, default: 0
    belongs_to :api_key, AiGuard.Billing.ApiKey

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(usage, attrs) do
    usage
    |> cast(attrs, [:api_key_id, :count])
    |> validate_required([:api_key_id])
  end
end
