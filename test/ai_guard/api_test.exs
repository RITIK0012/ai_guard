defmodule AiGuard.ApiTest do
  use AiGuard.DataCase

  alias AiGuard.Api

  describe "moderations" do
    alias AiGuard.Api.Moderation

    import AiGuard.AccountsFixtures, only: [user_scope_fixture: 0]
    import AiGuard.ApiFixtures

    @invalid_attrs %{text: nil, result: nil, api_key: nil}

    test "list_moderations/1 returns all scoped moderations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      other_moderation = moderation_fixture(other_scope)
      assert Api.list_moderations(scope) == [moderation]
      assert Api.list_moderations(other_scope) == [other_moderation]
    end

    test "get_moderation!/2 returns the moderation with given id" do
      scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      other_scope = user_scope_fixture()
      assert Api.get_moderation!(scope, moderation.id) == moderation
      assert_raise Ecto.NoResultsError, fn -> Api.get_moderation!(other_scope, moderation.id) end
    end

    test "create_moderation/2 with valid data creates a moderation" do
      valid_attrs = %{text: "some text", result: "some result", api_key: "some api_key"}
      scope = user_scope_fixture()

      assert {:ok, %Moderation{} = moderation} = Api.create_moderation(scope, valid_attrs)
      assert moderation.text == "some text"
      assert moderation.result == "some result"
      assert moderation.api_key == "some api_key"
      assert moderation.user_id == scope.user.id
    end

    test "create_moderation/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.create_moderation(scope, @invalid_attrs)
    end

    test "update_moderation/3 with valid data updates the moderation" do
      scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      update_attrs = %{text: "some updated text", result: "some updated result", api_key: "some updated api_key"}

      assert {:ok, %Moderation{} = moderation} = Api.update_moderation(scope, moderation, update_attrs)
      assert moderation.text == "some updated text"
      assert moderation.result == "some updated result"
      assert moderation.api_key == "some updated api_key"
    end

    test "update_moderation/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      moderation = moderation_fixture(scope)

      assert_raise MatchError, fn ->
        Api.update_moderation(other_scope, moderation, %{})
      end
    end

    test "update_moderation/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Api.update_moderation(scope, moderation, @invalid_attrs)
      assert moderation == Api.get_moderation!(scope, moderation.id)
    end

    test "delete_moderation/2 deletes the moderation" do
      scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      assert {:ok, %Moderation{}} = Api.delete_moderation(scope, moderation)
      assert_raise Ecto.NoResultsError, fn -> Api.get_moderation!(scope, moderation.id) end
    end

    test "delete_moderation/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      assert_raise MatchError, fn -> Api.delete_moderation(other_scope, moderation) end
    end

    test "change_moderation/2 returns a moderation changeset" do
      scope = user_scope_fixture()
      moderation = moderation_fixture(scope)
      assert %Ecto.Changeset{} = Api.change_moderation(scope, moderation)
    end
  end
end
