defmodule AiGuardWeb.UsageLive do
  use AiGuardWeb, :live_view
  import Ecto.Query

  alias AiGuard.Repo
  alias AiGuard.Billing
  alias AiGuard.Billing.ApiKey

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    api_keys =
      Repo.all(
        from k in ApiKey,
        where: k.user_id == ^user.id
      )

    usage_data =
      Enum.map(api_keys, fn key ->
        count = Billing.get_usage_for_key(key.id)
        %{key: key.key, count: count}
      end)

    {:ok, assign(socket, usage_data: usage_data)}
  end
end
