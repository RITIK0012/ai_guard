defmodule AiGuard.BillingFixtures do
  @moduledoc """
  Test helpers for Billing context.
  """

  alias AiGuard.Billing

  def api_key_fixture(scope, attrs \\ %{}) do
    {:ok, api_key} = Billing.create_api_key(scope, attrs)
    api_key
  end

  def usage_fixture(api_key_id) do
    Billing.increment_usage(api_key_id)
  end
end
