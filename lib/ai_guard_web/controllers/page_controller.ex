defmodule AiGuardWeb.PageController do
  use AiGuardWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
