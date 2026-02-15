defmodule AiGuardWeb.PageLive.Form do
  use AiGuardWeb, :live_view

  alias AiGuard.Dashboard
  alias AiGuard.Dashboard.Page

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage page records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="page-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Page</.button>
          <.button navigate={return_path(@current_scope, @return_to, @page)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    page = Dashboard.get_page!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, page)
    |> assign(:form, to_form(Dashboard.change_page(socket.assigns.current_scope, page)))
  end

  defp apply_action(socket, :new, _params) do
    page = %Page{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, page)
    |> assign(:form, to_form(Dashboard.change_page(socket.assigns.current_scope, page)))
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    changeset = Dashboard.change_page(socket.assigns.current_scope, socket.assigns.page, page_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    save_page(socket, socket.assigns.live_action, page_params)
  end

  defp save_page(socket, :edit, page_params) do
    case Dashboard.update_page(socket.assigns.current_scope, socket.assigns.page, page_params) do
      {:ok, page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, page)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_page(socket, :new, page_params) do
    case Dashboard.create_page(socket.assigns.current_scope, page_params) do
      {:ok, page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, page)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _page), do: ~p"/dashboards"
  defp return_path(_scope, "show", page), do: ~p"/dashboards/#{page}"
end
