defmodule AiGuard.Billing do
  @moduledoc "Billing context"

  import Ecto.Query, warn: false
  alias AiGuard.Repo
  alias AiGuard.Billing.{ApiKey, Usage}
  alias AiGuard.Accounts.Scope

  @free_tier 10
  @price_per_call 0.005

  # ================= API KEYS =================

  def list_api_keys(%Scope{} = scope) do
    Repo.all_by(ApiKey, user_id: scope.user.id)
  end

  def revoke_api_key(id) do
    key = Repo.get!(ApiKey, id)

    key
    |> Ecto.Changeset.change(
      revoked_at: DateTime.utc_now() |> DateTime.truncate(:second)
    )
    |> Repo.update()
  end

  # ================= USAGE =================

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

  def get_usage_for_key(api_key_id) do
    case Repo.get_by(Usage, api_key_id: api_key_id) do
      nil -> 0
      usage -> usage.count
    end
  end

  # ================= RATE LIMIT =================
  # 🔥 FIXED: function now exists

  def rate_limited?(api_key_id, limit \\ 5) do
    one_minute_ago =
      DateTime.utc_now()
      |> DateTime.add(-60, :second)

    count =
      Repo.aggregate(
        from(m in "moderations",
          where:
            m.api_key == ^get_key_string(api_key_id) and
              m.inserted_at > ^one_minute_ago
        ),
        :count
      )

    count >= limit
  end

  defp get_key_string(api_key_id) do
    Repo.get!(ApiKey, api_key_id).key
  end

  # ================= COST =================

  def cost_for_key(api_key_id) do
    calls = get_usage_for_key(api_key_id)

    billable =
      if calls > @free_tier do
        calls - @free_tier
      else
        0
      end

    Float.round(billable * @price_per_call, 4)
  end

  def total_cost(api_keys) do
    api_keys
    |> Enum.map(&cost_for_key(&1.id))
    |> Enum.sum()
    |> Float.round(4)
  end

  # ================= MONTHLY USAGE =================

  def monthly_usage(api_key_id) do
    today = Date.utc_today()

    months =
      for i <- 5..0 do
        date = Date.add(today, -i * 30)
        {date.year, date.month}
      end

    query =
      from u in Usage,
        where: u.api_key_id == ^api_key_id,
        group_by: fragment("date_trunc('month', ?)", u.inserted_at),
        select: {
          fragment("date_trunc('month', ?)", u.inserted_at),
          sum(u.count)
        }

    results =
      Repo.all(query)
      |> Enum.map(fn {date, count} ->
        {{date.year, date.month}, count}
      end)
      |> Map.new()

    Enum.map(months, fn {year, month} ->
      label = "#{month_name(month)} #{year}"
      {label, Map.get(results, {year, month}, 0)}
    end)
  end

  defp month_name(m) do
    ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    |> Enum.at(m - 1)
  end

  # ================= INVOICE =================

  def monthly_invoice(api_key_id) do
    monthly_usage(api_key_id)
    |> Enum.map(fn {month, calls} ->
      billable = max(calls - @free_tier, 0)
      cost = Float.round(billable * @price_per_call, 2)

      %{
        month: month,
        calls: calls,
        billable_calls: billable,
        cost: cost
      }
    end)
  end

  def billing_csv(api_key_id) do
    header = "Month,Calls,Billable Calls,Cost"

    rows =
      monthly_invoice(api_key_id)
      |> Enum.map(fn row ->
        "#{row.month},#{row.calls},#{row.billable_calls},#{row.cost}"
      end)

    Enum.join([header | rows], "\n")
  end
end
