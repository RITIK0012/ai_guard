defmodule AiGuardWeb.PageLive.Index do
  use AiGuardWeb, :live_view

  alias AiGuard.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Dashboards
        <:actions>
          <.button variant="primary" navigate={~p"/dashboards/new"}>
            <.icon name="hero-plus" /> New Page
          </.button>
        </:actions>
      </.header>

      <.table
        id="dashboards"
        rows={@streams.dashboards}
        row_click={fn {_id, page} -> JS.navigate(~p"/dashboards/#{page}") end}
      >
        <:col :let={{_id, page}} label="Title">{page.title}</:col>
        <:action :let={{_id, page}}>
          <div class="sr-only">
            <.link navigate={~p"/dashboards/#{page}"}>Show</.link>
          </div>
          <.link navigate={~p"/dashboards/#{page}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, page}}>
          <.link
            phx-click={JS.push("delete", value: %{id: page.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Dashboard.subscribe_dashboards(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Dashboards")
     |> stream(:dashboards, list_dashboards(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Dashboard.get_page!(socket.assigns.current_scope, id)
    {:ok, _} = Dashboard.delete_page(socket.assigns.current_scope, page)

    {:noreply, stream_delete(socket, :dashboards, page)}
  end

  @impl true
  def handle_info({type, %AiGuard.Dashboard.Page{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :dashboards, list_dashboards(socket.assigns.current_scope), reset: true)}
  end

  defp list_dashboards(current_scope) do
    Dashboard.list_dashboards(current_scope)
  end
end
