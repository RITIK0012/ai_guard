defmodule AiGuard.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AiGuard.Billing` context.
  """

  @doc """
  Generate a api_key.
  """
  def api_key_fixture(scope, attrs \\ %{}) do
  attrs =
    Enum.into(attrs, %{})

  {:ok, api_key} = AiGuard.Billing.create_api_key(attrs, scope)
  api_key
end

end
