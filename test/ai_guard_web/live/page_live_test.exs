defmodule AiGuardWeb.PageLiveTest do
  use AiGuardWeb.ConnCase

  import Phoenix.LiveViewTest
  import AiGuard.DashboardFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  setup :register_and_log_in_user

  defp create_page(%{scope: scope}) do
    page = page_fixture(scope)

    %{page: page}
  end

  describe "Index" do
    setup [:create_page]

    test "lists all dashboards", %{conn: conn, page: page} do
      {:ok, _index_live, html} = live(conn, ~p"/dashboards")

      assert html =~ "Listing Dashboards"
      assert html =~ page.title
    end

    test "saves new page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboards")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Page")
               |> render_click()
               |> follow_redirect(conn, ~p"/dashboards/new")

      assert render(form_live) =~ "New Page"

      assert form_live
             |> form("#page-form", page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#page-form", page: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dashboards")

      html = render(index_live)
      assert html =~ "Page created successfully"
      assert html =~ "some title"
    end

    test "updates page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboards")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#dashboards-#{page.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/dashboards/#{page}/edit")

      assert render(form_live) =~ "Edit Page"

      assert form_live
             |> form("#page-form", page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#page-form", page: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dashboards")

      html = render(index_live)
      assert html =~ "Page updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboards")

      assert index_live |> element("#dashboards-#{page.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#dashboards-#{page.id}")
    end
  end

  describe "Show" do
    setup [:create_page]

    test "displays page", %{conn: conn, page: page} do
      {:ok, _show_live, html} = live(conn, ~p"/dashboards/#{page}")

      assert html =~ "Show Page"
      assert html =~ page.title
    end

    test "updates page and returns to show", %{conn: conn, page: page} do
      {:ok, show_live, _html} = live(conn, ~p"/dashboards/#{page}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/dashboards/#{page}/edit?return_to=show")

      assert render(form_live) =~ "Edit Page"

      assert form_live
             |> form("#page-form", page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#page-form", page: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dashboards/#{page}")

      html = render(show_live)
      assert html =~ "Page updated successfully"
      assert html =~ "some updated title"
    end
  end
end
