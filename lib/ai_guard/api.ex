defmodule AiGuard.Api do
  @moduledoc """
  The Api context.
  """

  import Ecto.Query, warn: false
  alias AiGuard.Repo

  alias AiGuard.Api.Moderation
  alias AiGuard.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any moderation changes.

  The broadcasted messages match the pattern:

    * {:created, %Moderation{}}
    * {:updated, %Moderation{}}
    * {:deleted, %Moderation{}}

  """
  def subscribe_moderations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(AiGuard.PubSub, "user:#{key}:moderations")
  end

  defp broadcast_moderation(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(AiGuard.PubSub, "user:#{key}:moderations", message)
  end

  @doc """
  Returns the list of moderations.

  ## Examples

      iex> list_moderations(scope)
      [%Moderation{}, ...]

  """
  def list_moderations(%Scope{} = scope) do
    Repo.all_by(Moderation, user_id: scope.user.id)
  end

  @doc """
  Gets a single moderation.

  Raises `Ecto.NoResultsError` if the Moderation does not exist.

  ## Examples

      iex> get_moderation!(scope, 123)
      %Moderation{}

      iex> get_moderation!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_moderation!(%Scope{} = scope, id) do
    Repo.get_by!(Moderation, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a moderation.

  ## Examples

      iex> create_moderation(scope, %{field: value})
      {:ok, %Moderation{}}

      iex> create_moderation(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_moderation(%Scope{} = scope, attrs) do
    with {:ok, moderation = %Moderation{}} <-
           %Moderation{}
           |> Moderation.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_moderation(scope, {:created, moderation})
      {:ok, moderation}
    end
  end

  @doc """
  Updates a moderation.

  ## Examples

      iex> update_moderation(scope, moderation, %{field: new_value})
      {:ok, %Moderation{}}

      iex> update_moderation(scope, moderation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_moderation(%Scope{} = scope, %Moderation{} = moderation, attrs) do
    true = moderation.user_id == scope.user.id

    with {:ok, moderation = %Moderation{}} <-
           moderation
           |> Moderation.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_moderation(scope, {:updated, moderation})
      {:ok, moderation}
    end
  end

  @doc """
  Deletes a moderation.

  ## Examples

      iex> delete_moderation(scope, moderation)
      {:ok, %Moderation{}}

      iex> delete_moderation(scope, moderation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_moderation(%Scope{} = scope, %Moderation{} = moderation) do
    true = moderation.user_id == scope.user.id

    with {:ok, moderation = %Moderation{}} <-
           Repo.delete(moderation) do
      broadcast_moderation(scope, {:deleted, moderation})
      {:ok, moderation}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking moderation changes.

  ## Examples

      iex> change_moderation(scope, moderation)
      %Ecto.Changeset{data: %Moderation{}}

  """
  def change_moderation(%Scope{} = scope, %Moderation{} = moderation, attrs \\ %{}) do
    true = moderation.user_id == scope.user.id

    Moderation.changeset(moderation, attrs, scope)
  end
end
