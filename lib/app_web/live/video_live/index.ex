defmodule AppWeb.VideoLive.Index do
  use AppWeb, :live_view

  alias App.Videos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Videos
        <:actions>
          <.button variant="primary" navigate={~p"/videos/new"}>
            <.icon name="hero-plus" /> New Video
          </.button>
        </:actions>
      </.header>

      <.table
        id="videos"
        rows={@streams.videos}
        row_click={fn {_id, video} -> JS.navigate(~p"/videos/#{video}") end}
      >
        <:col :let={{_id, video}} label="Name">{video.name}</:col>
        <:action :let={{_id, video}}>
          <div class="sr-only">
            <.link navigate={~p"/videos/#{video}"}>Show</.link>
          </div>
          <.link navigate={~p"/videos/#{video}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, video}}>
          <.link
            phx-click={JS.push("delete", value: %{id: video.id}) |> hide("##{id}")}
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
