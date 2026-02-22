defmodule AiGuardWeb.UsageLive do
  use AiGuardWeb, :live_view
  import Ecto.Query

  alias AiGuard.Repo
  alias AiGuard.Billing
  alias AiGuard.Billing.ApiKey

  def mount(_params, _session, socket) do
    {:ok, load_usage(socket)}
  end

  # Revoke key
  def handle_event("revoke", %{"id" => id}, socket) do
    Billing.revoke_api_key(String.to_integer(id))
    {:noreply, load_usage(socket)}
  end

  # Load data
  defp load_usage(socket) do
    user = socket.assigns.current_scope.user

    api_keys =
      Repo.all(from k in ApiKey, where: k.user_id == ^user.id and is_nil(k.revoked_at))

    usage_data =
      Enum.map(api_keys, fn key ->
        count = Billing.get_usage_for_key(key.id)
        cost = Billing.cost_for_key(key.id)
        short = String.slice(key.key, -4, 4)

        %{
          id: key.id,
          key: key.key,
          label: "Key ••••#{short}",
          full_key: key.key,
          count: count,
          cost: cost
        }
      end)

    # Monthly aggregated usage
    monthly =
      api_keys
      |> Enum.flat_map(&Billing.monthly_usage(&1.id))
      |> Enum.group_by(fn {month, _} -> month end)
      |> Enum.map(fn {month, entries} ->
        total = Enum.sum(Enum.map(entries, fn {_, count} -> count end))
        {month, total}
      end)
      |> Enum.sort()

    assign(socket,
      usage_data: usage_data,
      monthly_labels: Enum.map(monthly, &elem(&1, 0)),
      monthly_values: Enum.map(monthly, &elem(&1, 1)),
      total_cost: Billing.total_cost(api_keys)
    )
  end
end
