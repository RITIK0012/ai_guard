defmodule AiGuardWeb.ModerationJSON do
  alias AiGuard.Api.Moderation

  @doc """
  Renders a list of moderations.
  """
  def index(%{moderations: moderations}) do
    %{data: for(moderation <- moderations, do: data(moderation))}
  end

  @doc """
  Renders a single moderation.
  """
  def show(%{moderation: moderation}) do
    %{data: data(moderation)}
  end

  defp data(%Moderation{} = moderation) do
    %{
      id: moderation.id,
      text: moderation.text,
      result: moderation.result,
      api_key: moderation.api_key
    }
  end
end
