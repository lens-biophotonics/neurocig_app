defmodule AppWeb.VideoLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.VideosFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_video(_) do
    video = video_fixture()

    %{video: video}
  end

  describe "Index" do
    setup [:create_video]

    test "lists all videos", %{conn: conn, video: video} do
      {:ok, _index_live, html} = live(conn, ~p"/videos")

      assert html =~ "Listing Videos"
      assert html =~ video.name
    end

    test "saves new video", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/videos")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Video")
               |> render_click()
               |> follow_redirect(conn, ~p"/videos/new")

      assert render(form_live) =~ "New Video"

      assert form_live
             |> form("#video-form", video: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#video-form", video: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/videos")

      html = render(index_live)
      assert html =~ "Video created successfully"
      assert html =~ "some name"
    end

    test "updates video in listing", %{conn: conn, video: video} do
      {:ok, index_live, _html} = live(conn, ~p"/videos")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#videos-#{video.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/videos/#{video}/edit")

      assert render(form_live) =~ "Edit Video"

      assert form_live
             |> form("#video-form", video: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#video-form", video: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/videos")

      html = render(index_live)
      assert html =~ "Video updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes video in listing", %{conn: conn, video: video} do
      {:ok, index_live, _html} = live(conn, ~p"/videos")

      assert index_live |> element("#videos-#{video.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#videos-#{video.id}")
    end
  end

  describe "Show" do
    setup [:create_video]

    test "displays video", %{conn: conn, video: video} do
      {:ok, _show_live, html} = live(conn, ~p"/videos/#{video}")

      assert html =~ "Show Video"
      assert html =~ video.name
    end

    test "updates video and returns to show", %{conn: conn, video: video} do
      {:ok, show_live, _html} = live(conn, ~p"/videos/#{video}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/videos/#{video}/edit?return_to=show")

      assert render(form_live) =~ "Edit Video"

      assert form_live
             |> form("#video-form", video: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#video-form", video: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/videos/#{video}")

      html = render(show_live)
      assert html =~ "Video updated successfully"
      assert html =~ "some updated name"
    end
  end
end
