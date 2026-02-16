defmodule AiGuardWeb.ModerationControllerTest do
  use AiGuardWeb.ConnCase

  import AiGuard.ApiFixtures
  alias AiGuard.Api.Moderation

  @create_attrs %{
    text: "some text",
    result: "some result",
    api_key: "some api_key"
  }
  @update_attrs %{
    text: "some updated text",
    result: "some updated result",
    api_key: "some updated api_key"
  }
  @invalid_attrs %{text: nil, result: nil, api_key: nil}

  setup :register_and_log_in_user

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all moderations", %{conn: conn} do
      conn = get(conn, ~p"/api/moderations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create moderation" do
    test "renders moderation when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/moderations", moderation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/moderations/#{id}")

      assert %{
               "id" => ^id,
               "api_key" => "some api_key",
               "result" => "some result",
               "text" => "some text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/moderations", moderation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update moderation" do
    setup [:create_moderation]

    test "renders moderation when data is valid", %{conn: conn, moderation: %Moderation{id: id} = moderation} do
      conn = put(conn, ~p"/api/moderations/#{moderation}", moderation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/moderations/#{id}")

      assert %{
               "id" => ^id,
               "api_key" => "some updated api_key",
               "result" => "some updated result",
               "text" => "some updated text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, moderation: moderation} do
      conn = put(conn, ~p"/api/moderations/#{moderation}", moderation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete moderation" do
    setup [:create_moderation]

    test "deletes chosen moderation", %{conn: conn, moderation: moderation} do
      conn = delete(conn, ~p"/api/moderations/#{moderation}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/moderations/#{moderation}")
      end
    end
  end

  defp create_moderation(%{scope: scope}) do
    moderation = moderation_fixture(scope)

    %{moderation: moderation}
  end
end
