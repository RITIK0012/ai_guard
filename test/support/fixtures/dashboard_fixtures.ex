defmodule AiGuard.DashboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AiGuard.Dashboard` context.
  """

  @doc """
  Generate a page.
  """
  def page_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "some title"
      })

    {:ok, page} = AiGuard.Dashboard.create_page(scope, attrs)
    page
  end
end
