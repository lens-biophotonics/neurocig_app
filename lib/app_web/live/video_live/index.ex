defmodule AppWeb.VideoLive.Index do
  use AppWeb, :live_view

  alias App.Videos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.table
        id="videos"
        rows={@streams.videos}
        row_click={fn {_id, video} -> JS.navigate(~p"/videos/#{video}") end}
      >
        <:col :let={{_id, video}} label="Name">{video.name}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Videos")
     |> stream(:videos, list_videos())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    video = Videos.get_video!(id)
    {:ok, _} = Videos.delete_video(video)

    {:noreply, stream_delete(socket, :videos, video)}
  end

  defp list_videos() do
    Videos.list_videos()
  end
end
