defmodule AiGuardWeb.ModerationController do
  use AiGuardWeb, :controller

  alias AiGuard.Repo
  alias AiGuard.Billing.ApiKey
  alias AiGuard.Api
  alias AiGuard.Billing
  import Ecto.Query

  # 🚦 Max requests per minute per API key
  @rate_limit 5

  # POST /api/moderate
  def create(conn, %{"text" => text}) do
    with ["Bearer " <> key] <- get_req_header(conn, "authorization"),
         {:ok, api_key} <- validate_api_key(key),
         false <- Billing.rate_limited?(api_key.id, @rate_limit) do

      result = moderate_text(text)

      # Fetch user & build scope
      user = Repo.get!(AiGuard.Accounts.User, api_key.user_id)
      scope = AiGuard.Accounts.Scope.for_user(user)

      {:ok, _record} =
        Api.create_moderation(scope, %{
          text: text,
          result: result,
          api_key: api_key.key,
          user_id: api_key.user_id
        })

      # increment usage counter
      Billing.increment_usage(api_key.id)

      json(conn, %{result: result})

    else
      true ->
        conn
        |> put_status(429)
        |> json(%{error: "Rate limit exceeded. Try again in a minute."})

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or missing API key"})
    end
  end

  # 🔐 Validate API key (SAFE VERSION)
  defp validate_api_key(key) do
    query =
      from a in ApiKey,
        where: a.key == ^key and is_nil(a.revoked_at)

    case Repo.one(query) do
      nil -> {:error, :invalid}
      api_key -> {:ok, api_key}
    end
  end

  # 🧠 Basic moderation logic
  defp moderate_text(text) do
    toxic_words = ["hate", "kill", "stupid"]

    if Enum.any?(toxic_words, &String.contains?(String.downcase(text), &1)) do
      "toxic"
    else
      "clean"
    end
  end
end
