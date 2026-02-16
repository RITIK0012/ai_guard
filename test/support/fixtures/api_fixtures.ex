defmodule AiGuard.ApiFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AiGuard.Api` context.
  """

  @doc """
  Generate a moderation.
  """
  def moderation_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        api_key: "some api_key",
        result: "some result",
        text: "some text"
      })

    {:ok, moderation} = AiGuard.Api.create_moderation(scope, attrs)
    moderation
  end
end
