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

  ## Examples

      iex> list_api_keys(scope)
      [%ApiKey{}, ...]

  """
  def list_api_keys(%Scope{} = scope) do
    Repo.all_by(ApiKey, user_id: scope.user.id)
  end

  @doc """
  Gets a single api_key.

  Raises `Ecto.NoResultsError` if the Api key does not exist.

  ## Examples

      iex> get_api_key!(scope, 123)
      %ApiKey{}

      iex> get_api_key!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_api_key!(%Scope{} = scope, id) do
    Repo.get_by!(ApiKey, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a api_key.

  ## Examples

      iex> create_api_key(scope, %{field: value})
      {:ok, %ApiKey{}}

      iex> create_api_key(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

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
  Updates a api_key.

  ## Examples

      iex> update_api_key(scope, api_key, %{field: new_value})
      {:ok, %ApiKey{}}

      iex> update_api_key(scope, api_key, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

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
  Deletes a api_key.

  ## Examples

      iex> delete_api_key(scope, api_key)
      {:ok, %ApiKey{}}

      iex> delete_api_key(scope, api_key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_api_key(%Scope{} = scope, %ApiKey{} = api_key) do
    true = api_key.user_id == scope.user.id

    with {:ok, api_key = %ApiKey{}} <-
           Repo.delete(api_key) do
      broadcast_api_key(scope, {:deleted, api_key})
      {:ok, api_key}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking api_key changes.

  ## Examples

      iex> change_api_key(scope, api_key)
      %Ecto.Changeset{data: %ApiKey{}}

  """
  def change_api_key(%Scope{} = scope, %ApiKey{} = api_key, attrs \\ %{}) do
    true = api_key.user_id == scope.user.id

    ApiKey.changeset(api_key, attrs, scope)
  end
end
