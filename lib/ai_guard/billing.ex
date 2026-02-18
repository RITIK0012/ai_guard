defmodule AiGuard.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias AiGuard.Repo

  alias AiGuard.Billing.ApiKey
  alias AiGuard.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any api_key changes.

  The broadcasted messages match the pattern:

    * {:created, %ApiKey{}}
    * {:updated, %ApiKey{}}
    * {:deleted, %ApiKey{}}
  """
  def subscribe_api_keys(%Scope{} = scope) do
    key = scope.user.id
    Phoenix.PubSub.subscribe(AiGuard.PubSub, "user:#{key}:api_keys")
  end

  defp broadcast_api_key(%Scope{} = scope, message) do
    key = scope.user.id
    Phoenix.PubSub.broadcast(AiGuard.PubSub, "user:#{key}:api_keys", message)
  end

  @doc """
  Returns the list of api_keys.
  """
  def list_api_keys(%Scope{} = scope) do
    Repo.all_by(ApiKey, user_id: scope.user.id)
  end

  @doc """
  Gets a single api_key.
  """
  def get_api_key!(%Scope{} = scope, id) do
    Repo.get_by!(ApiKey, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates an api_key.
  """
  def create_api_key(%Scope{} = scope, attrs) do
    with {:ok, api_key = %ApiKey{}} <-
           %ApiKey{}
           |> ApiKey.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_api_key(scope, {:created, api_key})
      {:ok, api_key}
    end
  end

  @doc """
  Updates an api_key.
  """
  def update_api_key(%Scope{} = scope, %ApiKey{} = api_key, attrs) do
    true = api_key.user_id == scope.user.id

    with {:ok, api_key = %ApiKey{}} <-
           api_key
           |> ApiKey.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_api_key(scope, {:updated, api_key})
      {:ok, api_key}
    end
  end

  @doc """
  Deletes an api_key.
  """
  def delete_api_key(%Scope{} = scope, %ApiKey{} = api_key) do
    true = api_key.user_id == scope.user.id

    with {:ok, api_key = %ApiKey{}} <- Repo.delete(api_key) do
      broadcast_api_key(scope, {:deleted, api_key})
      {:ok, api_key}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking api_key changes.
  """
  def change_api_key(%Scope{} = scope, %ApiKey{} = api_key, attrs \\ %{}) do
    true = api_key.user_id == scope.user.id
    ApiKey.changeset(api_key, attrs, scope)
  end

  # =========================
  # USAGE TRACKING
  # =========================

  alias AiGuard.Billing.Usage

  # Increment usage for an API key
  def increment_usage(api_key_id) do
    case Repo.get_by(Usage, api_key_id: api_key_id) do
      nil ->
        %Usage{}
        |> Usage.changeset(%{api_key_id: api_key_id, count: 1})
        |> Repo.insert()

      usage ->
        usage
        |> Usage.changeset(%{count: usage.count + 1})
        |> Repo.update()
    end
  end

  # Get usage count for an API key
  def get_usage_for_key(api_key_id) do
    case Repo.get_by(Usage, api_key_id: api_key_id) do
      nil -> 0
      usage -> usage.count
    end
  end

  # =========================
  # REVOKE API KEY
  # =========================

  @doc """
  Revokes an API key by setting revoked_at timestamp.
  """
  def revoke_api_key(id) do
  key = Repo.get!(ApiKey, id)

  key
  |> Ecto.Changeset.change(
    revoked_at: DateTime.utc_now() |> DateTime.truncate(:second)
  )
  |> Repo.update()
end

end
