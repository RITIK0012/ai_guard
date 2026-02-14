defmodule AiGuard.Repo do
  use Ecto.Repo,
    otp_app: :ai_guard,
    adapter: Ecto.Adapters.Postgres
end
