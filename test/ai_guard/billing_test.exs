defmodule AiGuard.BillingTest do
  use AiGuard.DataCase

  alias AiGuard.Billing

  describe "api_keys" do
    alias AiGuard.Billing.ApiKey

    import AiGuard.AccountsFixtures, only: [user_scope_fixture: 0]
    import AiGuard.BillingFixtures

    @invalid_attrs %{"\\": nil}

    test "list_api_keys/1 returns all scoped api_keys" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      other_api_key = api_key_fixture(other_scope)
      assert Billing.list_api_keys(scope) == [api_key]
      assert Billing.list_api_keys(other_scope) == [other_api_key]
    end

    test "get_api_key!/2 returns the api_key with given id" do
      scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      other_scope = user_scope_fixture()
      assert Billing.get_api_key!(scope, api_key.id) == api_key
      assert_raise Ecto.NoResultsError, fn -> Billing.get_api_key!(other_scope, api_key.id) end
    end

    test "create_api_key/2 with valid data creates a api_key" do
      valid_attrs = %{"\\": "some \\"}
      scope = user_scope_fixture()

      assert {:ok, %ApiKey{} = api_key} = Billing.create_api_key(scope, valid_attrs)
      assert api_key.\ == "some \\"
      assert api_key.user_id == scope.user.id
    end

    test "create_api_key/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.create_api_key(scope, @invalid_attrs)
    end

    test "update_api_key/3 with valid data updates the api_key" do
      scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      update_attrs = %{"\\": "some updated \\"}

      assert {:ok, %ApiKey{} = api_key} = Billing.update_api_key(scope, api_key, update_attrs)
      assert api_key.\ == "some updated \\"
    end

    test "update_api_key/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      api_key = api_key_fixture(scope)

      assert_raise MatchError, fn ->
        Billing.update_api_key(other_scope, api_key, %{})
      end
    end

    test "update_api_key/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Billing.update_api_key(scope, api_key, @invalid_attrs)
      assert api_key == Billing.get_api_key!(scope, api_key.id)
    end

    test "delete_api_key/2 deletes the api_key" do
      scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      assert {:ok, %ApiKey{}} = Billing.delete_api_key(scope, api_key)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_api_key!(scope, api_key.id) end
    end

    test "delete_api_key/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      assert_raise MatchError, fn -> Billing.delete_api_key(other_scope, api_key) end
    end

    test "change_api_key/2 returns a api_key changeset" do
      scope = user_scope_fixture()
      api_key = api_key_fixture(scope)
      assert %Ecto.Changeset{} = Billing.change_api_key(scope, api_key)
    end
  end

  describe "usages" do
    alias AiGuard.Billing.Usage

    import AiGuard.AccountsFixtures, only: [user_scope_fixture: 0]
    import AiGuard.BillingFixtures

    @invalid_attrs %{"\\": nil}

    test "list_usages/1 returns all scoped usages" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      usage = usage_fixture(scope)
      other_usage = usage_fixture(other_scope)
      assert Billing.list_usages(scope) == [usage]
      assert Billing.list_usages(other_scope) == [other_usage]
    end

    test "get_usage!/2 returns the usage with given id" do
      scope = user_scope_fixture()
      usage = usage_fixture(scope)
      other_scope = user_scope_fixture()
      assert Billing.get_usage!(scope, usage.id) == usage
      assert_raise Ecto.NoResultsError, fn -> Billing.get_usage!(other_scope, usage.id) end
    end

    test "create_usage/2 with valid data creates a usage" do
      valid_attrs = %{"\\": "some \\"}
      scope = user_scope_fixture()

      assert {:ok, %Usage{} = usage} = Billing.create_usage(scope, valid_attrs)
      assert usage.\ == "some \\"
      assert usage.user_id == scope.user.id
    end

    test "create_usage/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.create_usage(scope, @invalid_attrs)
    end

    test "update_usage/3 with valid data updates the usage" do
      scope = user_scope_fixture()
      usage = usage_fixture(scope)
      update_attrs = %{"\\": "some updated \\"}

      assert {:ok, %Usage{} = usage} = Billing.update_usage(scope, usage, update_attrs)
      assert usage.\ == "some updated \\"
    end

    test "update_usage/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      usage = usage_fixture(scope)

      assert_raise MatchError, fn ->
        Billing.update_usage(other_scope, usage, %{})
      end
    end

    test "update_usage/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      usage = usage_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Billing.update_usage(scope, usage, @invalid_attrs)
      assert usage == Billing.get_usage!(scope, usage.id)
    end

    test "delete_usage/2 deletes the usage" do
      scope = user_scope_fixture()
      usage = usage_fixture(scope)
      assert {:ok, %Usage{}} = Billing.delete_usage(scope, usage)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_usage!(scope, usage.id) end
    end

    test "delete_usage/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      usage = usage_fixture(scope)
      assert_raise MatchError, fn -> Billing.delete_usage(other_scope, usage) end
    end

    test "change_usage/2 returns a usage changeset" do
      scope = user_scope_fixture()
      usage = usage_fixture(scope)
      assert %Ecto.Changeset{} = Billing.change_usage(scope, usage)
    end
  end
end
