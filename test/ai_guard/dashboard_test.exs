defmodule AiGuard.DashboardTest do
  use AiGuard.DataCase

  alias AiGuard.Dashboard

  describe "dashboards" do
    alias AiGuard.Dashboard.Page

    import AiGuard.AccountsFixtures, only: [user_scope_fixture: 0]
    import AiGuard.DashboardFixtures

    @invalid_attrs %{title: nil}

    test "list_dashboards/1 returns all scoped dashboards" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      page = page_fixture(scope)
      other_page = page_fixture(other_scope)
      assert Dashboard.list_dashboards(scope) == [page]
      assert Dashboard.list_dashboards(other_scope) == [other_page]
    end

    test "get_page!/2 returns the page with given id" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      other_scope = user_scope_fixture()
      assert Dashboard.get_page!(scope, page.id) == page
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_page!(other_scope, page.id) end
    end

    test "create_page/2 with valid data creates a page" do
      valid_attrs = %{title: "some title"}
      scope = user_scope_fixture()

      assert {:ok, %Page{} = page} = Dashboard.create_page(scope, valid_attrs)
      assert page.title == "some title"
      assert page.user_id == scope.user.id
    end

    test "create_page/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_page(scope, @invalid_attrs)
    end

    test "update_page/3 with valid data updates the page" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Page{} = page} = Dashboard.update_page(scope, page, update_attrs)
      assert page.title == "some updated title"
    end

    test "update_page/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      page = page_fixture(scope)

      assert_raise MatchError, fn ->
        Dashboard.update_page(other_scope, page, %{})
      end
    end

    test "update_page/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_page(scope, page, @invalid_attrs)
      assert page == Dashboard.get_page!(scope, page.id)
    end

    test "delete_page/2 deletes the page" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      assert {:ok, %Page{}} = Dashboard.delete_page(scope, page)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_page!(scope, page.id) end
    end

    test "delete_page/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      page = page_fixture(scope)
      assert_raise MatchError, fn -> Dashboard.delete_page(other_scope, page) end
    end

    test "change_page/2 returns a page changeset" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      assert %Ecto.Changeset{} = Dashboard.change_page(scope, page)
    end
  end
end
