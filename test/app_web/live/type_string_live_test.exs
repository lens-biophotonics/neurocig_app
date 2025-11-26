defmodule AppWeb.TypeStringLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.BehaviorFixtures

  @create_attrs %{type_string: "some type_string"}
  @update_attrs %{type_string: "some updated type_string"}
  @invalid_attrs %{type_string: nil}
  defp create_type_string(_) do
    type_string = type_string_fixture()

    %{type_string: type_string}
  end

  describe "Index" do
    setup [:create_type_string]

    test "lists all type_strings", %{conn: conn, type_string: type_string} do
      {:ok, _index_live, html} = live(conn, ~p"/type_strings")

      assert html =~ "Listing Type strings"
      assert html =~ type_string.type_string
    end

    test "saves new type_string", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/type_strings")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Type string")
               |> render_click()
               |> follow_redirect(conn, ~p"/type_strings/new")

      assert render(form_live) =~ "New Type string"

      assert form_live
             |> form("#type_string-form", type_string: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#type_string-form", type_string: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/type_strings")

      html = render(index_live)
      assert html =~ "Type string created successfully"
      assert html =~ "some type_string"
    end

    test "updates type_string in listing", %{conn: conn, type_string: type_string} do
      {:ok, index_live, _html} = live(conn, ~p"/type_strings")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#type_strings-#{type_string.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/type_strings/#{type_string}/edit")

      assert render(form_live) =~ "Edit Type string"

      assert form_live
             |> form("#type_string-form", type_string: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#type_string-form", type_string: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/type_strings")

      html = render(index_live)
      assert html =~ "Type string updated successfully"
      assert html =~ "some updated type_string"
    end

    test "deletes type_string in listing", %{conn: conn, type_string: type_string} do
      {:ok, index_live, _html} = live(conn, ~p"/type_strings")

      assert index_live |> element("#type_strings-#{type_string.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#type_strings-#{type_string.id}")
    end
  end

  describe "Show" do
    setup [:create_type_string]

    test "displays type_string", %{conn: conn, type_string: type_string} do
      {:ok, _show_live, html} = live(conn, ~p"/type_strings/#{type_string}")

      assert html =~ "Show Type string"
      assert html =~ type_string.type_string
    end

    test "updates type_string and returns to show", %{conn: conn, type_string: type_string} do
      {:ok, show_live, _html} = live(conn, ~p"/type_strings/#{type_string}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/type_strings/#{type_string}/edit?return_to=show")

      assert render(form_live) =~ "Edit Type string"

      assert form_live
             |> form("#type_string-form", type_string: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#type_string-form", type_string: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/type_strings/#{type_string}")

      html = render(show_live)
      assert html =~ "Type string updated successfully"
      assert html =~ "some updated type_string"
    end
  end
end
