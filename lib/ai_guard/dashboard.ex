defmodule AiGuard.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false
  alias AiGuard.Repo

  alias AiGuard.Dashboard.Page
  alias AiGuard.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any page changes.

  The broadcasted messages match the pattern:

    * {:created, %Page{}}
    * {:updated, %Page{}}
    * {:deleted, %Page{}}

  """
  def subscribe_dashboards(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(AiGuard.PubSub, "user:#{key}:dashboards")
  end

  defp broadcast_page(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(AiGuard.PubSub, "user:#{key}:dashboards", message)
  end

  @doc """
  Returns the list of dashboards.

  ## Examples

      iex> list_dashboards(scope)
      [%Page{}, ...]

  """
  def list_dashboards(%Scope{} = scope) do
    Repo.all_by(Page, user_id: scope.user.id)
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(scope, 123)
      %Page{}

      iex> get_page!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(%Scope{} = scope, id) do
    Repo.get_by!(Page, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(scope, %{field: value})
      {:ok, %Page{}}

      iex> create_page(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(%Scope{} = scope, attrs) do
    with {:ok, page = %Page{}} <-
           %Page{}
           |> Page.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_page(scope, {:created, page})
      {:ok, page}
    end
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(scope, page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(scope, page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Scope{} = scope, %Page{} = page, attrs) do
    true = page.user_id == scope.user.id

    with {:ok, page = %Page{}} <-
           page
           |> Page.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_page(scope, {:updated, page})
      {:ok, page}
    end
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(scope, page)
      {:ok, %Page{}}

      iex> delete_page(scope, page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Scope{} = scope, %Page{} = page) do
    true = page.user_id == scope.user.id

    with {:ok, page = %Page{}} <-
           Repo.delete(page) do
      broadcast_page(scope, {:deleted, page})
      {:ok, page}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(scope, page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Scope{} = scope, %Page{} = page, attrs \\ %{}) do
    true = page.user_id == scope.user.id

    Page.changeset(page, attrs, scope)
  end
end
