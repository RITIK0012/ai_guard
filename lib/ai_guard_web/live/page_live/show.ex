defmodule AiGuardWeb.PageLive.Show do
  use AiGuardWeb, :live_view

  alias AiGuard.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Page {@page.id}
        <:subtitle>This is a page record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/dashboards"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/dashboards/#{@page}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit page
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@page.title}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Dashboard.subscribe_dashboards(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Page")
     |> assign(:page, Dashboard.get_page!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %AiGuard.Dashboard.Page{id: id} = page},
        %{assigns: %{page: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :page, page)}
  end

  def handle_info(
        {:deleted, %AiGuard.Dashboard.Page{id: id}},
        %{assigns: %{page: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current page was deleted.")
     |> push_navigate(to: ~p"/dashboards")}
  end

  def handle_info({type, %AiGuard.Dashboard.Page{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
