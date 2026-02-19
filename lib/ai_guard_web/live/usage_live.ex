defmodule AiGuardWeb.UsageLive do
  use AiGuardWeb, :live_view
  import Ecto.Query

  alias AiGuard.Repo
  alias AiGuard.Billing
  alias AiGuard.Billing.ApiKey

  # 🔹 Load data
  def mount(_params, _session, socket) do
    {:ok, load_usage(socket)}
  end

  # 🔹 Handle Revoke Button
  def handle_event("revoke", %{"id" => id}, socket) do
    Billing.revoke_api_key(id)
    {:noreply, load_usage(socket)}
  end

  # 🔹 Reload usage data
  defp load_usage(socket) do
    user = socket.assigns.current_scope.user

    api_keys =
      Repo.all(
        from k in ApiKey,
        where: k.user_id == ^user.id and is_nil(k.revoked_at)
      )

    usage_data =
      Enum.map(api_keys, fn key ->
        count = Billing.get_usage_for_key(key.id)

        short =
          key.key
          |> String.slice(-4, 4)

        %{
          id: key.id,
          key: key.key,
          label: "Key ••••#{short}",
          full_key: key.key,
          count: count
        }
      end)

    assign(socket, usage_data: usage_data)
  end
end
